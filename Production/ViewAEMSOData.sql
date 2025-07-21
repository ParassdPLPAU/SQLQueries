
/*
    ViewAEMSOData.sql

    This SQL view aggregates sales order release data for AEM parts, including job tree details, scheduling, and firm status.

    - Identifies open sales order releases for parts associated with AEM (via PersonID or Planner).
    - Recursively builds the full job tree for each release, including subassemblies.
    - Determines the firm status of jobs (AllFirmed, AllUnfirmed, Mixed) per release.
    - Aggregates job scheduling data to provide earliest start and latest due dates for each release, which provides you with the timeline of the entire SO.
    - Joins with sales order and order detail tables to provide comprehensive order information.
    - Outputs order dates, release identifiers, scheduling summary, order line details, and job firm status.
    - Results are ordered by the earliest job start date.

    Tables referenced:
        - erp.OrderRel
        - erp.PartPlant
        - erp.JobProd
        - erp.JobHead
        - dbo.OrderDtl
        - erp.OrderHed
*/

-- First: Get all relevant order releases with AEM parts
WITH AEMReleases AS (
    SELECT 
        OrderNum,
        OrderLine,
        OrderRelNum,
        PartNum
    FROM erp.OrderRel
    WHERE PartNum IN (
        SELECT PartNum FROM erp.PartPlant WHERE PersonID LIKE '%AEM%'
    )
    AND OpenRelease = 1
),

-- Recursive CTE to get full job tree per release
JobTree AS (
    -- Anchor: Get initial jobs linked to the order releases
    SELECT 
        jp.JobNum,
        jh.JobFirm,
        jp.PartNum,
        jp.ProdQty,
        jp.OrderNum,
        jp.OrderLine,
        jp.OrderRelNum,
        jp.TargetJobNum,
        jp.TargetAssemblySeq,
        jp.TargetMtlSeq,
        0 AS lvl
    FROM erp.JobProd jp
	--WHERE OrderNum = '2365262'
	--AND OrderLine = '4'
	--AND OrderRelNum = '1'
    INNER JOIN AEMReleases r 
        ON jp.OrderNum = r.OrderNum 
        AND jp.OrderLine = r.OrderLine 
        AND jp.OrderRelNum = r.OrderRelNum
    LEFT JOIN erp.JobHead jh ON jp.JobNum = jh.JobNum
--) SELECT * FROM JobTree
    UNION ALL

    -- Recursive: Get jobs where current job is a subassembly
    SELECT 
        jp.JobNum,
        jh.JobFirm,
        jp.PartNum,
        jp.ProdQty,
        COALESCE(jt.OrderNum,jp.OrderNum),
        COALESCE(jt.OrderLine,jp.OrderLine),
        COALESCE(jt.OrderRelNum,jp.OrderRelNum),
        jp.TargetJobNum,
        jp.TargetAssemblySeq,
        jp.TargetMtlSeq,
        jt.lvl + 1
    FROM erp.JobProd jp
    INNER JOIN JobTree jt ON jp.TargetJobNum = jt.JobNum
    INNER JOIN erp.JobHead jh ON jp.JobNum = jh.JobNum
    WHERE jp.TargetJobNum IS NOT NULL
), CheckFirmStatus AS (
    SELECT OrderNum, OrderLine, OrderRelNum,
           CASE 
               WHEN MIN(CAST(JobFirm AS INT)) = 1 THEN 'AllFirmed'
               WHEN MAX(CAST(JobFirm AS INT)) = 0 THEN 'AllUnfirmed'
               ELSE 'Mixed'
           END AS Firm_Flag 
    FROM JobTree JT
    GROUP BY OrderNum, OrderLine, OrderRelNum
),
-- Add scheduling info
JobSchedule AS (
    SELECT 
        jt.OrderNum,
        jt.OrderLine,
        jt.OrderRelNum,
        jt.JobNum,
        jt.PartNum,
        jt.ProdQty,
		--sched.StartDate,
		--sched.DueDate
        MIN(sched.StartDate) AS StartDate,
        MAX(sched.DueDate) AS DueDate
    FROM JobTree jt
    INNER JOIN erp.JobHead sched ON jt.JobNum = sched.JobNum
    GROUP BY jt.OrderNum, jt.OrderLine, jt.OrderRelNum, jt.JobNum, jt.PartNum, jt.ProdQty
),

-- Aggregate start/end dates across the full job tree for each SO release
TimelineSummary AS (
    SELECT 
        OrderNum,
        OrderLine,
        OrderRelNum,
        MIN(StartDate) AS EarliestStart,
        MAX(DueDate) AS LatestDue
    FROM JobSchedule
    GROUP BY OrderNum, OrderLine, OrderRelNum
)

-- Final output
SELECT 
    OH.OrderDate,
    ts.OrderNum,
    ts.OrderLine,
    ts.OrderRelNum,
    ts.EarliestStart,
    ts.LatestDue,
    OD.OpenLine,
    OD.VoidLine,
    OD.PartNum,
    OD.LineDesc,
    OD.RevisionNum,
    OD.OrderQty,
    OD.DocUnitPrice,
    OD.NeedByDate,
    OD.RequestDate,
    OD.Promise_Date_c,
    cfs.Firm_Flag
FROM TimelineSummary ts
INNER JOIN dbo.OrderDtl OD ON ts.OrderNum = OD.ordernum AND ts.orderline = OD.orderline
INNER JOIN erp.OrderHed OH ON ts.OrderNum = OH.ordernum
LEFT JOIN CheckFirmStatus cfs ON ts.OrderNum = cfs.OrderNum AND ts.OrderLine = cfs.OrderLine AND ts.OrderRelNum = cfs.OrderRelNum
WHERE OD.OpenLine = 1
ORDER BY ts.EarliestStart