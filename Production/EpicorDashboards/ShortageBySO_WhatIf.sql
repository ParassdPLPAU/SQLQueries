/*
    ShortageBySO.sql

    Author: Paras Sood
    Role: IT Manager at PLP Australia
    Created Date: 15-07-2025
    Last Updated: 29-08-2025

    This query calculates material shortages by sales order using recursive CTEs to trace job and material requirements using WHAT IF scenarios for scheduling.

    What if scenarios are dates that are planned scheduled dates without actually committing to them in the system. This is useful for planning job dates and comparing your potential
    load vs capacity issues along with material shortages.

    Steps:
    1. ANCHOR: Recursively builds a job tree for a given sales order, starting from erp.JobProd and joining erp.JobOper.
    2. PartWhseQOH: Aggregates on-hand quantities for each part from erp.PartWhse.
    3. Base_RunningBalance: Calculates running balances for material requirements from erp.PartDtl. Update to WHAT IF dates for jobs
    4. DailySums: Sums daily net quantities for each part and due date.
    5. DailyRunningBalances: Computes running daily balances for each part, factoring in on-hand quantities.
    6. ShortageCheck: Joins job material requirements with running balances and part sourcing info to identify shortages.
    7. Final SELECT: Returns shortage records for each job/material combination, ordered by job level.

    Output columns include job, part, order, material, due dates, running balances, and shortage status.

    This only works if you have used the make to job feature in Epicor since it relies on the TargetJobNum field in JobProd to be populated.

    UPDATE: This version contains a fix that compares the what if dates with all of the jobs what if dates from timephase
    If you don't compare with what if dates then you run the risk of seeing dates where there are no apparent shortages because 
    you haven't accounted for the job you are rescheduling to consume stock as well. 
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
	WHERE OrderNum <> 0 AND OrderNum IS NOT NULL  --Add parameters here ie ordernum,line and rel so that you only select jobs for a particular sales order.
	AND OrderNum = '2359381' AND OrderLine = 10 AND OrderRelNum = 1 --Change this to your order number, line and rel

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
        0 AS 'RN',
        PartNum,
        CAST(GETDATE() AS date) AS 'TP_WI_DueDate',
        SUM(OnHandQty) AS 'NetDailyQty',
        SUM(OnHandQty) AS 'DailyBalance'
        FROM erp.PartWhse
        WHERE OnHandQty <> 0
        GROUP BY PartNum
),WISchedule AS (
    SELECT PD.Company, PD.Type, PD.PartNum, PD.DueDate, JH.WIStartDate,
        CASE 
            WHEN (PD.JobNum IS NULL OR PD.JobNum = '') THEN PD.DueDate 
            ELSE 
                CASE
                    WHEN (PD.RequirementFlag = 1) THEN 
                    CASE 
                        WHEN (JM.WIReqDate = JM.ReqDate) THEN JM.WIReqDate
                        ELSE DATEADD(day,-1,JM.WIReqDate)
                    END
                    ELSE JH.WIDueDate
                END
        END AS 'WIDueDate',
        PD.RequirementFlag, PD.Quantity,
        CASE WHEN RequirementFlag = 0 THEN Quantity ELSE Quantity*-1 END AS 'StockQty',
        PD.JobNum,
        PD.AssemblySeq,
        PD.JobSeq
        FROM erp.PartDtl PD
        LEFT JOIN erp.JobHead JH ON PD.JobNum = JH.JobNum AND PD.PartNum = JH.PartNum AND RequirementFlag = 0
        LEFT JOIN erp.JobMtl JM ON PD.JobNum = JM.JobNum AND PD.PartNum = JM.PartNum AND RequirementFlag = 1
        WHERE PD.Type = 'mtl' and StockTrans = 1
),Base_RunningBalance AS (
    SELECT 
        ROW_NUMBER () OVER (PARTITION BY WS.PartNum ORDER BY WS.WIDueDate) AS 'RN',
        WS.PartNum,
        WS.DueDate,
        WS.WIDueDate,
        WS.RequirementFlag,
        WS.StockQty,
        WS.JobNum,
        WS.AssemblySeq,
        WS.JobSeq
    FROM WISchedule WS
    LEFT JOIN erp.JobHead JH ON JH.JobNum = WS.JobNum AND JH.PartNum = WS.PartNum
) --SELECT * FROM Base_RunningBalance where partnum = 'A-ELC152340' order by WIDueDate
, DailySums AS (
    SELECT
        PartNum,
        WIDueDate,
        SUM(StockQty) AS NetDailyQty
    FROM Base_RunningBalance
    GROUP BY PartNum, WIDueDate
) --SELECT * FROM DailySums where partnum = 'A-ELC152340'
, DailyRunningBalances AS (
    SELECT 
        ROW_NUMBER () OVER (PARTITION BY DailySums.PartNum ORDER BY DailySums.WIDueDate) AS 'RN',
        DailySums.PartNum,
        DailySums.WIDueDate AS 'TP_WI_DueDate',
        DailySums.NetDailyQty,
        (COALESCE(PW.NetDailyQty,0) + SUM(DailySums.NetDailyQty) OVER (PARTITION BY DailySums.PartNum ORDER BY DailySums.WIDueDate))
        AS 'DailyBalance'
    FROM DailySums
    LEFT JOIN PartWhseQOH PW ON PW.PartNum = DailySums.PartNum
), DailyRunningBalancesWithSOH AS (
    SELECT 
        *
    FROM PartWhseQOH
    UNION ALL
    SELECT
        *
    FROM DailyRunningBalances
) --SELECT * FROM DailyRunningBalancesWithSOH order by partnum, rn
,ShortageCheck AS (
    SELECT 
        A.*,
        DRB.RN,
        JM.PartNum AS 'MtlPartNum',
        JM.AssemblySeq,
        JM.MtlSeq,
        PP.SourceType,
        ROW_NUMBER() OVER (PARTITION BY A.JobNum,JM.PartNum ORDER BY DRB.TP_WI_DueDate DESC) AS LatestTPRN,
        DRB.TP_WI_DueDate,
        DRB.NetDailyQty,
        DRB.DailyBalance AS 'RunningBalance',
        PP.LeadTime AS 'PurchaseLeadTime',
        PP.TotMfgLeadTimeSys AS 'ManufacturedLeadTime',
        CASE WHEN DRB.DailyBalance <= 0 THEN
            CASE 
                WHEN PP.SourceType = 'M' THEN
                    DATEADD(day, -PP.TotMfgLeadTimeSys, A.WIStartDate)
                WHEN PP.SourceType = 'P' THEN
                    DATEADD(day, -PP.LeadTime, A.WIStartDate)
                ELSE NULL
            END 
        END AS 'MOBDate'
    FROM Anchor A 
    LEFT JOIN erp.JobMtl JM ON JM.JobNum = A.JobNum
    LEFT JOIN DailyRunningBalancesWithSOH DRB ON JM.PartNum = DRB.PartNum AND TP_WI_DueDate <= A.WIStartDate
    INNER JOIN erp.PartPlant PP ON JM.PartNum = PP.PartNum AND PP.Plant = JM.Plant
)
SELECT ShortageCheck.*,DATEDIFF(day,MOBDate,GETDATE()) AS DaysLateMoB 
FROM 
ShortageCheck
where 
LatestTPRN = 1 AND 
TP_WI_DueDate IS NOT NULL 
--and jobnum = 'J104228' --and mtlpartnum = 'A-ELC152340'
order by DaysLateMoB desc
--order by lvl asc, WIStartDate desc