---- Step 1: Unroll LoadDays and LoadHours using recursive CTE
--WITH LoadCTE AS (
--    -- Anchor: First element of LoadDays/Hours
--    SELECT 
--        RTU.Company AS ResourceTimeUsed_Company,
--        RTU.ResourceGrpID AS ResourceTimeUsed_ResourceGrpID,
--        RTU.JobNum AS ResourceTimeUsed_JobNum,
--        RTU.AssemblySeq AS ResourceTimeUsed_AssemblySeq,
--        RTU.OprSeq AS ResourceTimeUsed_OprSeq,
--        RTU.OpDtlSeq AS ResourceTimeUsed_OpDtlSeq,
--        LEFT(RTU.LoadDays, CHARINDEX('~', RTU.LoadDays + '~') - 1) AS Calculated_LoadDate,
--        STUFF(RTU.LoadDays, 1, CHARINDEX('~', RTU.LoadDays + '~'), '') AS Calculated_LoadDates,
--        1 AS Calculated_LoadNum,
--        LEFT(RTU.LoadHours, CHARINDEX('~', RTU.LoadHours + '~') - 1) AS Calculated_LoadHour,
--        STUFF(RTU.LoadHours, 1, CHARINDEX('~', RTU.LoadHours + '~'), '') AS Calculated_LoadHours,
--        RTU.StartDate AS ResourceTimeUsed_StartDate,
--		0 AS TotalDayOffset
--    FROM Erp.ResourceTimeUsed RTU
--    WHERE RTU.WhatIf = 0 AND RTU.LoadDays <> ''-- and RTU.JobNum = 'J102193'

--	--SELECT * FROM erp.resourcetimeused where jobnum = '031485' and WhatIf = 0 AND LoadDays <> ''

--    UNION ALL

--    -- Recursive step: Next element of LoadDays/Hours
--    SELECT 
--        L.ResourceTimeUsed_Company,
--        L.ResourceTimeUsed_ResourceGrpID,
--        L.ResourceTimeUsed_JobNum,
--        L.ResourceTimeUsed_AssemblySeq,
--        L.ResourceTimeUsed_OprSeq,
--        L.ResourceTimeUsed_OpDtlSeq,
--        LEFT(L.Calculated_LoadDates, CHARINDEX('~', L.Calculated_LoadDates + '~') - 1),
--        STUFF(L.Calculated_LoadDates, 1, CHARINDEX('~', L.Calculated_LoadDates + '~'), ''),
--        L.Calculated_LoadNum + 1,
--        LEFT(L.Calculated_LoadHours, CHARINDEX('~', L.Calculated_LoadHours + '~') - 1),
--        STUFF(L.Calculated_LoadHours, 1, CHARINDEX('~', L.Calculated_LoadHours + '~'), ''),
--        L.ResourceTimeUsed_StartDate,
--		L.TotalDayOffset + (CAST(LEFT(L.RemainingLoadDays, CHARINDEX('~', L.RemainingLoadDays + '~') - 1) AS INT) - L.LoadDay)
--    FROM LoadCTE L
--    WHERE L.Calculated_LoadDates <> '' AND L.Calculated_LoadNum < 100
--),

---- Step 2: Recursive trace of JobNum to final sales order (Anchor)
--Anchor AS (
--    SELECT 
--        JP.JobNum,
--        JP.OrderNum,
--        JP.OrderLine,
--        JP.OrderRelNum,
--        JP.TargetJobNum,
--        0 AS Lvl,
--        JP.JobNum AS RootJob
--    FROM Erp.JobProd JP
--    INNER JOIN LoadCTE L ON JP.JobNum = L.ResourceTimeUsed_JobNum

--    UNION ALL

--    SELECT 
--        JP2.JobNum,
--        COALESCE(JP2.OrderNum, A.OrderNum),
--        COALESCE(JP2.OrderLine, A.OrderLine),
--        COALESCE(JP2.OrderRelNum, A.OrderRelNum),
--        JP2.TargetJobNum,
--        A.Lvl + 1,
--        A.RootJob
--    FROM Erp.JobProd JP2
--    INNER JOIN Anchor A ON JP2.JobNum = A.TargetJobNum
--),

---- Step 3: One record per root job with final order details
--AnchorSummary AS (
--    SELECT 
--        RootJob,
--        MAX(Lvl) AS MaxLevel,
--        MAX(OrderNum) AS FinalOrderNum,
--        MAX(OrderLine) AS FinalOrderLine,
--        MAX(OrderRelNum) AS FinalOrderRel
--    FROM Anchor
--    GROUP BY RootJob
--)

---- Step 4: Final output joining load with final order info
--SELECT 
--    L.ResourceTimeUsed_Company,
--    L.ResourceTimeUsed_ResourceGrpID,
--    L.ResourceTimeUsed_JobNum,
--    L.ResourceTimeUsed_AssemblySeq,
--    L.ResourceTimeUsed_OprSeq,
--    L.ResourceTimeUsed_OpDtlSeq,
--    L.Calculated_LoadDate,
--    L.Calculated_LoadDates,
--    L.Calculated_LoadNum,
--    L.Calculated_LoadHours,
--    L.ResourceTimeUsed_StartDate,
--    L.Calculated_LoadNum - 1 AS LoadNumFactor,
--    DATEADD(DAY, L.Calculated_LoadNum - 1, L.ResourceTimeUsed_StartDate) AS Calculated_LoadStartDate,
--    L.Calculated_LoadHour,
--    CONVERT(varchar, L.Calculated_LoadHour) AS Calculated_DecLoadHour,
--    JH.PartNum AS JobHead_PartNum,
--    JH.JobFirm AS JobHead_JobFirm,
--    ASum.FinalOrderNum,
--    ASum.FinalOrderLine,
--    ASum.FinalOrderRel,
--    ASum.MaxLevel
--FROM LoadCTE L
--INNER JOIN Erp.JobHead JH ON 
--    L.ResourceTimeUsed_Company = JH.Company AND 
--    L.ResourceTimeUsed_JobNum = JH.JobNum
--LEFT JOIN AnchorSummary ASum ON 
--    L.ResourceTimeUsed_JobNum = ASum.RootJob
--WHERE L.Calculated_LoadNum <> 0 and L.ResourceTimeUsed_ResourceGrpID = 'ASSY_AEM'

--Latest query
WITH ANCHOR  AS (
    SELECT 
        JobNum,
        PartNum,
        ProdQty,
		OrderNum,
		OrderLine,
		OrderRelNum,
        TargetJobNum,
        TargetAssemblySeq,
        TargetMtlSeq,
        0 as lvl
    FROM erp.JobProd
	WHERE OrderNum <> 0 AND OrderNum IS NOT NULL
	--WHERE OrderNum = '2365260'
	--AND OrderLine = '1'
	--AND OrderRelNum = '1'

    UNION ALL

    SELECT 
        jp.JobNum,
        jp.PartNum,
        jp.ProdQty,
        A.OrderNum,
		A.OrderLine,
		A.OrderRelNum,
        jp.TargetJobNum,
        jp.TargetAssemblySeq,
        jp.TargetMtlSeq,
        A.lvl + 1
    FROM ANCHOR A
    INNER JOIN erp.JobProd jp ON jp.TargetJobNum = A.JobNum
	WHERE jp.TargetJobNum IS NOT NULL 
) 
--SELECT * FROM ANCHOR a
,
LoadCTE AS (
    -- Anchor: First element of LoadDays/Hours
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
        RTU.StartDate AS ResourceTimeUsed_StartDate,
		LEFT(RTU.LoadDays, CHARINDEX('~', RTU.LoadDays + '~') - 1) AS PrevLoadDay,
		0 AS Calculated_LoadOffset
    FROM Erp.ResourceTimeUsed RTU
    WHERE RTU.WhatIf = 0 AND RTU.LoadDays <> ''-- and RTU.JobNum = 'J102193'

    UNION ALL

    -- Recursive step: Next element of LoadDays/Hours
    SELECT 
        L.ResourceTimeUsed_Company,
        L.ResourceTimeUsed_ResourceGrpID,
        L.ResourceTimeUsed_JobNum,
        L.ResourceTimeUsed_AssemblySeq,
        L.ResourceTimeUsed_OprSeq,
        L.ResourceTimeUsed_OpDtlSeq,
        LEFT(L.Calculated_LoadDates, CHARINDEX('~', L.Calculated_LoadDates + '~') - 1),
        STUFF(L.Calculated_LoadDates, 1, CHARINDEX('~', L.Calculated_LoadDates + '~'), ''),
        L.Calculated_LoadNum + 1,
        LEFT(L.Calculated_LoadHours, CHARINDEX('~', L.Calculated_LoadHours + '~') - 1),
        STUFF(L.Calculated_LoadHours, 1, CHARINDEX('~', L.Calculated_LoadHours + '~'), ''),
        L.ResourceTimeUsed_StartDate,
		LEFT(L.Calculated_LoadDates, CHARINDEX('~', L.Calculated_LoadDates + '~') - 1),
		L.Calculated_LoadOffset + LEFT(L.Calculated_LoadDates, CHARINDEX('~', L.Calculated_LoadDates + '~') - 1) - L.PrevLoadDay
    FROM LoadCTE L
    WHERE L.Calculated_LoadDates <> '' AND L.Calculated_LoadNum < 100
) --SELECT * FROM LoadCTE order by ResourceTimeUsed_JobNum
, 

BASE AS (

SELECT 
    L.ResourceTimeUsed_Company,
    L.ResourceTimeUsed_ResourceGrpID,
    L.ResourceTimeUsed_JobNum,
    L.ResourceTimeUsed_AssemblySeq,
    L.ResourceTimeUsed_OprSeq,
    --L.Calculated_LoadDate,
    --L.Calculated_LoadDates,
    L.Calculated_LoadNum AS DayCount,
    --L.Calculated_LoadHours,
    L.ResourceTimeUsed_StartDate,
    --L.Calculated_LoadNum - 1 AS LoadNumFactor,
    DATEADD(DAY, L.Calculated_LoadOffset, L.ResourceTimeUsed_StartDate) AS Calculated_LoadStartDate,
    L.Calculated_LoadHour,
    --CONVERT(varchar, L.Calculated_LoadHour) AS Calculated_DecLoadHour,
    JH.PartNum AS JobHead_PartNum,Calculated_LoadOffset,
    JH.JobFirm AS JobHead_JobFirm,
	A.OrderNum,
	A.OrderLine,
	A.OrderRelNum
--FROM LoadCTE L
--INNER JOIN Erp.JobHead JH ON 
--    L.ResourceTimeUsed_Company = JH.Company AND 
--    L.ResourceTimeUsed_JobNum = JH.JobNum
--LEFT JOIN Anchor A ON 
--    L.ResourceTimeUsed_JobNum = A.JobNum
--WHERE L.Calculated_LoadNum <> 0 and L.ResourceTimeUsed_ResourceGrpID = 'ASSY_AEM'
--order by lvl asc

--FROM Anchor A 
--LEFT JOIN LoadCTE L ON L.ResourceTimeUsed_JobNum = A.JobNum
FROM LoadCTE L 
LEFT JOIN Anchor A ON L.ResourceTimeUsed_JobNum = A.JobNum
INNER JOIN Erp.JobHead JH ON 
    L.ResourceTimeUsed_Company = JH.Company AND 
    L.ResourceTimeUsed_JobNum = JH.JobNum
WHERE L.Calculated_LoadNum <> 0 
)

SELECT * FROM BASE --where Calculated_LoadStartDate = '2026-03-11' and ResourceTimeUsed_ResourceGrpID LIKE '%AEM%'
order by resourcetimeused_jobnum