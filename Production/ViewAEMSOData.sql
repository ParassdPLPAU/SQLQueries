--SELECT * FROM erp.PartPlant where PersonID LIKE '%AEM%'

--SELECT * FROM erp.OrderRel where PartNum IN (SELECT PartNum FROM erp.PartPlant where PersonID LIKE '%AEM%') AND OpenRelease = 1

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
--) SELECT * FROM JobTree
    UNION ALL

    -- Recursive: Get jobs where current job is a subassembly
    SELECT 
        jp.JobNum,
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
    WHERE jp.TargetJobNum IS NOT NULL
), --SELECT * FROM JobTree

-- Add scheduling info
JobSchedule AS (
    SELECT 
        jt.OrderNum,
        jt.OrderLine,
        jt.OrderRelNum,
        jt.JobNum,
		--sched.StartDate,
		--sched.DueDate
        MIN(sched.StartDate) AS StartDate,
        MAX(sched.DueDate) AS DueDate
    FROM JobTree jt
    INNER JOIN erp.JobHead sched ON jt.JobNum = sched.JobNum
    GROUP BY jt.OrderNum, jt.OrderLine, jt.OrderRelNum, jt.JobNum
)--SELECT * FROM JobSchedule
,

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
    ts.OrderNum,
    ts.OrderLine,
    ts.OrderRelNum,
    ts.EarliestStart,
    ts.LatestDue
FROM TimelineSummary ts
ORDER BY ts.EarliestStart