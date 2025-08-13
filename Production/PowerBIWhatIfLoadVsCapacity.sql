--Find load and capacity for areas where 

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
), FilterOnJobs AS (
	SELECT JobNum,
	CASE WHEN MAX(CASE WHEN WhatIf = 1 THEN 1 ELSE 0 END) = 1 THEN 1
	ELSE 0
	END AS SelectedWhatIfJob
	FROM erp.ResourceTimeUsed
	--WHERE JobNum = 'J102985'
	GROUP BY JobNum
),
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
		0 AS Calculated_LoadOffset,
		WhatIf
    FROM Erp.ResourceTimeUsed RTU
	INNER JOIN FilterOnJobs JF ON JF.JobNum = RTU.JobNum AND JF.SelectedWhatIfJob = RTU.WhatIf
    WHERE 
	--RTU.WhatIf = 0 AND 
	RTU.LoadDays <> '' --and 
	--RTU.JobNum = 'J102985'

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
		L.Calculated_LoadOffset + LEFT(L.Calculated_LoadDates, CHARINDEX('~', L.Calculated_LoadDates + '~') - 1) - L.PrevLoadDay,
		WhatIf
    FROM LoadCTE L
    WHERE L.Calculated_LoadDates <> '' AND L.Calculated_LoadNum < 100
) --SELECT * FROM LoadCTE 
,ShopCapCTE AS (
    SELECT 
        SC.Company,
        SC.ResourceGrpID,
        SC.LoadDate LoadDate,
        SC.Capacity,
        UD.Number01,
        UD.Character01,
        (SC.Capacity + ISNULL(UD.Number01, 0)) AS Calculated_Planned_Capacity
    FROM Erp.ShopCap SC
    LEFT JOIN Ice.UD04 UD
        ON SC.Company = UD.Company
        AND SC.ResourceGrpID = UD.Key1
        AND SC.LoadDate = UD.Date01
    WHERE SC.ResourceID = ''
), bounds AS (
    SELECT 
        MIN(SC.LoadDate) AS StartDate,
        MAX(DATEADD(DAY, L.Calculated_LoadOffset, L.ResourceTimeUsed_StartDate)) AS EndDate
    FROM ShopCapCTE SC
    LEFT JOIN LoadCTE L
        ON SC.ResourceGrpID = L.ResourceTimeUsed_ResourceGrpID 
       AND SC.LoadDate = DATEADD(DAY, L.Calculated_LoadOffset, L.ResourceTimeUsed_StartDate)
), CalendarCTE AS (
    SELECT DATEADD(DAY, n, StartDate) AS CalendarDate
    FROM bounds
    CROSS APPLY (
        SELECT TOP (DATEDIFF(DAY, StartDate, EndDate) + 1)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects -- or master..spt_values if needed
    ) AS X
), ResourceGroups AS (
    SELECT DISTINCT ResourceGrpID FROM ShopCapCTE
)

-- Step: Create full calendar per Resource Group
, ResourceCalendar AS (
    SELECT 
        RG.ResourceGrpID AS 'RGResourceGrpID',
        C.CalendarDate AS 'RGCalendarDate'
    FROM ResourceGroups RG
    CROSS JOIN CalendarCTE C
) --SELECT * FROM CalendarCTE,
-- Step: Extract distinct Resource Groups

,BASE_2 AS (
	SELECT 
		RC.RGResourceGrpID,
		RC.RGCalendarDate,
		L.ResourceTimeUsed_JobNum,
		JH.PartNum,
		L.ResourceTimeUsed_AssemblySeq,
		L.ResourceTimeUsed_OprSeq,
		L.Calculated_LoadNum AS DayCount,
		L.ResourceTimeUsed_StartDate,
		SC.LoadDate,
		DATEADD(DAY, L.Calculated_LoadOffset, L.ResourceTimeUsed_StartDate) AS Calculated_LoadStartDate,
		ISNULL(L.Calculated_LoadHour, 0) AS LoadHrs,
		--JH.PartNum AS JobHead_PartNum,
		Calculated_LoadOffset,
		--JH.JobFirm AS JobHead_JobFirm,
		A.OrderNum,
		A.OrderLine,
		A.OrderRelNum,
		JH.JobFirm,
		JH.ProdQty AS TotalJobProdQty,
		CASE 
		WHEN (A.OrderNum IS NULL AND A.OrderLine IS NULL AND A.OrderRelNum IS NULL AND (CAST(Calculated_LoadHour AS float) <> 0)) THEN 'MTS'
		WHEN (A.OrderNum IS NULL AND A.OrderLine IS NULL AND A.OrderRelNum IS NULL AND (CAST(Calculated_LoadHour AS float) = 0) OR Calculated_LoadHour IS NULL) THEN 'NA'
	ELSE CONCAT(A.OrderNum,'/',A.OrderLine,'/',A.OrderRelNum)
	END AS 'SOLineRelPartNum',
		ROW_NUMBER() OVER (
			PARTITION BY RC.RGResourceGrpID, RC.RGCalendarDate
			ORDER BY RC.RGCalendarDate
		) AS rn,
		CASE WHEN 
			ROW_NUMBER() OVER (
				PARTITION BY RC.RGResourceGrpID, RC.RGCalendarDate
				ORDER BY RC.RGCalendarDate
			) = 1 THEN ISNULL(Calculated_Planned_Capacity, 0)
			ELSE 0 END AS Shop_Capacity,
	WhatIf
	FROM ResourceCalendar RC
	LEFT JOIN ShopCapCTE SC ON RC.RGCalendarDate = SC.LoadDate AND (RC.RGResourceGrpID = SC.ResourceGrpID OR SC.ResourceGrpID IS NULL)
	LEFT JOIN LoadCTE L ON L.ResourceTimeUsed_ResourceGrpID = RC.RGResourceGrpID AND SC.LoadDate = DATEADD(DAY, L.Calculated_LoadOffset, L.ResourceTimeUsed_StartDate)
	LEFT JOIN Anchor A ON L.ResourceTimeUsed_JobNum = A.JobNum
	LEFT JOIN JobHead JH ON L.ResourceTimeUsed_JobNum = JH.JobNum
) 

--SELECT * FROM BASE_2

--To analyse load vs capacity for each Resource Group and date and find out overloads for parts where jobs are getting created due to legacy data (before non-stock) and duplicate demand
, BASE_3 AS (
SELECT RGCalendarDate,RGResourceGrpID, SUM(CAST(LoadHrs as float)) as totalload FROM BASE_2
where SOLineRelPartNum = 'MTS'
GROUP BY RGCalendarDate, RGResourceGrpID
--ORDER BY SUM(CAST(LoadHrs as float))  desc
)

SELECT SUM(totalload) FROM BASE_3