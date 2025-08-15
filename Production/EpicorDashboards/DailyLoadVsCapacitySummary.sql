WITH LoadCTE AS (
    SELECT 
        RTU.Company AS ResourceTimeUsed_Company,
        RTU.ResourceGrpID AS ResourceTimeUsed_ResourceGrpID,
        RTU.JobNum AS ResourceTimeUsed_JobNum,
        RTU.AssemblySeq AS ResourceTimeUsed_AssemblySeq,
        RTU.OprSeq AS ResourceTimeUsed_OprSeq,
        RTU.OpDtlSeq AS ResourceTimeUsed_OpDtlSeq,
        LEFT(RTU.LoadDays, CHARINDEX('~', RTU.LoadDays + '~') - 1) AS Calculated_LoadDate,
        STUFF(RTU.LoadDays, 1, CHARINDEX('~', RTU.LoadDays + '~'), '') AS Calculated_LoadDates,
        1 AS Calculated_LoadNum,
        LEFT(RTU.LoadHours, CHARINDEX('~', RTU.LoadHours + '~') - 1) AS Calculated_LoadHour,
        STUFF(RTU.LoadHours, 1, CHARINDEX('~', RTU.LoadHours + '~'), '') AS Calculated_LoadHours,
        RTU.StartDate AS ResourceTimeUsed_StartDate
    FROM Erp.ResourceTimeUsed RTU
    WHERE RTU.WhatIf = 0 AND RTU.LoadDays <> ''

    UNION ALL

    SELECT 
        L1.ResourceTimeUsed_Company,
        L1.ResourceTimeUsed_ResourceGrpID,
        L1.ResourceTimeUsed_JobNum,
        L1.ResourceTimeUsed_AssemblySeq,
        L1.ResourceTimeUsed_OprSeq,
        L1.ResourceTimeUsed_OpDtlSeq,
        LEFT(L1.Calculated_LoadDates, CHARINDEX('~', L1.Calculated_LoadDates + '~') - 1),
        STUFF(L1.Calculated_LoadDates, 1, CHARINDEX('~', L1.Calculated_LoadDates + '~'), ''),
        L1.Calculated_LoadNum + 1,
        LEFT(L1.Calculated_LoadHours, CHARINDEX('~', L1.Calculated_LoadHours + '~') - 1),
        STUFF(L1.Calculated_LoadHours, 1, CHARINDEX('~', L1.Calculated_LoadHours + '~'), ''),
        L1.ResourceTimeUsed_StartDate
    FROM LoadCTE L1
    WHERE L1.Calculated_LoadDates <> '' AND L1.Calculated_LoadNum <= 100
),

SumRG_Hour_date AS (
    SELECT 
        L.ResourceTimeUsed_ResourceGrpID,
        DATEADD(DAY, L.Calculated_LoadNum - 1, L.ResourceTimeUsed_StartDate) AS Calculated_LoadStartDate,
        SUM(ABS(TRY_CAST(L.Calculated_LoadHour AS DECIMAL(10,2)))) AS Calculated_SumLoadHour
    FROM LoadCTE L
    WHERE L.Calculated_LoadNum <> 0
    GROUP BY 
        L.ResourceTimeUsed_ResourceGrpID,
        DATEADD(DAY, L.Calculated_LoadNum - 1, L.ResourceTimeUsed_StartDate)
)

SELECT 
    SC.ResourceGrpID AS ShopCap_ResourceGrpID,
    SC.LoadDate AS ShopCap_LoadDate,
    SC.Capacity AS ShopCap_Capacity,
    UD.Number01 AS UD04_Number01,
    UD.Character01 AS UD04_Character01,
    (SC.Capacity + ISNULL(UD.Number01, 0)) AS Calculated_Planned_Capacity,
    SRH.Calculated_SumLoadHour AS Calculated_SumLoadHour,
    ISNULL(SRH.Calculated_SumLoadHour, 0) - (SC.Capacity + ISNULL(UD.Number01, 0)) AS Calculated_Under_Overload
FROM Erp.ShopCap SC
LEFT JOIN SumRG_Hour_date SRH
    ON SC.ResourceGrpID = SRH.ResourceTimeUsed_ResourceGrpID
    AND SC.LoadDate = SRH.Calculated_LoadStartDate
LEFT JOIN Ice.UD04 UD
    ON SC.Company = UD.Company
    AND SC.ResourceGrpID = UD.Key1
    AND SC.LoadDate = UD.Date01
WHERE SC.ResourceID = '' AND SC.LoadDate >= GETDATE();
