/*
    Author: Paras Sood
    Role: IT Manager at PLP Australia
    Date Created: 02-09-2025
    Date Last Updated: 02-09-2025

    Description:
    This SQL script calculates the running balance of parts in a warehouse based on scheduled requirements and current stock on hand.
    This is meant to replace the timephase data shown in Epicor with the duedates according to the rescheduled WI due dates.
    It uses several Common Table Expressions (CTEs) to:
      - Aggregate current on-hand quantities per part (PartWhseQOH).
      - Extract and transform WI (What If) schedule data from jobs (WISchedule).
      - Rank scheduled requirements by due date for each part (WIScheduleRanks).
      - Calculate the running balance for each part by combining stock on hand and scheduled requirements (Base_RunningBalance).
    The final SELECT returns the running balance for each part, ordered by part number and rank.

    Tables referenced:
      - erp.PartWhse: Contains part warehouse quantities.
      - erp.PartDtl: Contains part detail and requirement information.
      - erp.JobHead: Contains job header information.
      - erp.JobMtl: Contains job material requirement information.

    Usage:
      - Uncomment the relevant SELECT statements to filter by specific part numbers or to view daily summaries.
      - Adjust WHERE clauses as needed for targeted analysis.
*/


WITH PartWhseQOH AS (
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
    SELECT
        PD.Company, PD.Type, PD.PartNum, PD.DueDate, JH.WIStartDate,
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
        WHERE PD.Type = 'mtl'
), WIScheduleRanks AS (
    SELECT 
        ROW_NUMBER () OVER (PARTITION BY WS.PartNum ORDER BY WS.WIDueDate) AS 'RN',
        WS.*
    FROM WISchedule WS
)
,Base_RunningBalance AS (
    SELECT
        WSR.rn,
        WSR.PartNum,
        WSR.DueDate,
        WSR.WIDueDate,
        WSR.RequirementFlag,
        WSR.StockQty,
        WSR.JobNum,
        WSR.AssemblySeq,
        WSR.JobSeq,
        (COALESCE(PW.NetDailyQty,0) + SUM(WSR.StockQty) OVER (PARTITION BY WSR.PartNum ORDER BY WSR.RN)) AS 'Balance'
    FROM WIScheduleRanks WSR
    LEFT JOIN PartWhseQOH PW ON PW.PartNum = WSR.PartNum
    UNION ALL
    SELECT 
        0 AS 'RN',
        PW.PartNum,
        PW.TP_WI_DueDate AS 'DueDate',
        PW.TP_WI_DueDate AS 'WIDueDate',
        0 AS 'RequirementFlag',
        PW.NetDailyQty AS 'StockQty',
        'StockOnHand' AS 'JobNum',
        NULL AS 'AssemblySeq',
        NULL AS 'JobSeq',
        PW.NetDailyQty AS 'Balance'
    FROM PartWhseQOH PW
) SELECT * FROM Base_RunningBalance order by partnum, rn