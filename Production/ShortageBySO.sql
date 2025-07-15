/*
    ShortageBySO.sql

    Author: Paras Sood
    Role: IT Manager at PLP Australia
    Date: 15-07-2025

    This query calculates material shortages by sales order using recursive CTEs to trace job and material requirements.

    Steps:
    1. ANCHOR: Recursively builds a job tree for a given sales order, starting from erp.JobProd and joining erp.JobOper.
    2. PartWhseQOH: Aggregates on-hand quantities for each part from erp.PartWhse.
    3. Base_RunningBalance: Calculates running balances for material requirements from erp.PartDtl.
    4. DailySums: Sums daily net quantities for each part and due date.
    5. DailyRunningBalances: Computes running daily balances for each part, factoring in on-hand quantities.
    6. ShortageCheck: Joins job material requirements with running balances and part sourcing info to identify shortages.
    7. Final SELECT: Returns shortage records for each job/material combination, ordered by job level.

    Output columns include job, part, order, material, due dates, running balances, and shortage status.

    This only works if you have used the make to job feature in Epicor since it reli on the TargetJobNum field in JobProd to be populated.
*/
WITH ANCHOR  AS (
    SELECT 
        JP.JobNum,
        JP.PartNum,
        JO.StartDate,
        JO.DueDate,
        JO.WIStartDate,
        JO.WIDueDate,
        JP.ProdQty,
		JP.OrderNum,
		JP.OrderLine,
		JP.OrderRelNum,
        JP.TargetJobNum,
        JP.TargetAssemblySeq,
        JP.TargetMtlSeq, 
        0 as lvl
    FROM erp.JobProd JP
    INNER JOIN erp.JobOper JO ON JO.JobNum = JP.JobNum 
	WHERE OrderNum <> 0 AND OrderNum IS NOT NULL --Add parameters here ie ordernum,line and rel so that you only select jobs for a particular sales order.
	
    UNION ALL

    SELECT 
        jp.JobNum,
        jp.PartNum,
        JO.StartDate,
        JO.DueDate,
        JO.WIStartDate,
        JO.WIDueDate,
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
    INNER JOIN erp.JobOper JO ON JO.JobNum = JP.JobNum --AND JO.AssemblySeq = JP.AssemblySeq
	WHERE jp.TargetJobNum IS NOT NULL 
),PartWhseQOH AS (
    SELECT 
        PartNum,
        SUM(OnHandQty) AS 'TotalQOH'
        FROM erp.PartWhse
        WHERE OnHandQty <> 0
        GROUP BY PartNum
),Base_RunningBalance AS (
    SELECT 
        ROW_NUMBER () OVER (PARTITION BY PartNum ORDER BY DueDate) AS 'RN',
        PartNum,
        DueDate,
        RequirementFlag,
        Quantity,
        CASE WHEN RequirementFlag = 0 THEN Quantity ELSE Quantity*-1 END AS 'StockQty',
        JobNum,
        AssemblySeq,
        JobSeq
    FROM erp.PartDtl WHERE PartDtl.type = 'mtl' and stocktrans = 1
), DailySums AS (
    SELECT
        PartNum,
        DueDate,
        SUM(StockQty) AS NetDailyQty
    FROM Base_RunningBalance
    GROUP BY PartNum, DueDate
), DailyRunningBalances AS (
    SELECT 
        ROW_NUMBER () OVER (PARTITION BY DailySums.PartNum ORDER BY DailySums.DueDate) AS 'RN',
        DailySums.PartNum,
        DailySums.DueDate AS 'TPDueDate',
        DailySums.NetDailyQty,
        (COALESCE(PW.TotalQOH,0) + SUM(NetDailyQty) OVER (PARTITION BY DailySums.PartNum ORDER BY DailySums.DueDate))
        AS 'DailyBalance'
    FROM DailySums
    LEFT JOIN PartWhseQOH PW ON PW.PartNum = DailySums.PartNum
), ShortageCheck AS (
    SELECT 
        A.*,
        DRB.RN,
        JM.PartNum AS 'MtlPartNum',
        JM.AssemblySeq,
        JM.MtlSeq,
        PP.SourceType,
        ROW_NUMBER() OVER (PARTITION BY A.JobNum,JM.PartNum ORDER BY DRB.TPDueDate DESC) AS LatestTPRN,
        DRB.TPDueDate,
        DRB.NetDailyQty,
        DRB.DailyBalance AS 'RunningBalance'
    FROM Anchor A 
    LEFT JOIN erp.JobMtl JM ON JM.JobNum = A.JobNum
    LEFT JOIN DailyRunningBalances DRB ON JM.PartNum = DRB.PartNum AND TPDueDate <= A.StartDate
    INNER JOIN erp.PartPlant PP ON JM.PartNum = PP.PartNum AND PP.Plant = JM.Plant
    
)
SELECT * FROM 
ShortageCheck
where LatestTPRN = 1 AND TPDueDate IS NOT NULL
order by lvl asc