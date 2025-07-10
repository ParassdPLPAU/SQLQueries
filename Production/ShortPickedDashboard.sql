WITH ShortPicked AS (
    SELECT 
        ReqDate,
        JobComplete,
        IssuedComplete,
        JobNum,
        MtlSeq,
        PartNum,
        Description,
        QtyPer,
        RequiredQty,
        IUM,
        LeadTime,
        RelatedOperation,
        IssuedQty,
        RequiredQty - IssuedQty AS Balance,
        RevisionNum,
        Plant,
        Direct
    FROM erp.JobMtl 
    WHERE jobcomplete = 0 
        AND issuedcomplete = 0 
        AND jobnum NOT LIKE '%U%'
        AND IssuedQty < RequiredQty
        AND issuedqty <> 0
),
StockOnHand AS (
    SELECT 
        PartNum, 
        SUM(OnHandQty) AS TotalOnHandQty
    FROM erp.PartWhse 
    GROUP BY PartNum
),
Incoming AS (
    SELECT 
        PartNum,
        MIN(DueDate) AS NextDueDate,
        SUM(InvtyQty) AS IncomingQty
    FROM erp.PartDtl 
    WHERE 
        RequirementFlag = 0 
        AND InvtyQty > 0
    GROUP BY PartNum
)

SELECT 
    sp.JobNum,
	JH.StartDate,
	JH.DueDate,
	JH.ReqDueDate,
	JH.PartNum,
	JH.PersonID,
	JH.ProdQty,
    sp.PartNum AS 'MtlPartNum',
    sp.Description AS 'MtlDescription',
    sp.ReqDate AS 'MtlReqDate',
    sp.RequiredQty,
    sp.IssuedQty,
    sp.Balance,
    ISNULL(soh.TotalOnHandQty, 0) AS OnHandQty,
    CASE 
        WHEN ISNULL(soh.TotalOnHandQty, 0) >= sp.Balance THEN 'Available'
        WHEN ISNULL(inc.NextDueDate, NULL) IS NOT NULL THEN 'Incoming'
        ELSE 'Short'
    END AS Status,
    inc.NextDueDate,
    inc.IncomingQty
FROM ShortPicked sp
LEFT JOIN StockOnHand soh ON sp.PartNum = soh.PartNum
LEFT JOIN Incoming inc ON sp.PartNum = inc.PartNum
INNER JOIN erp.JobHead JH ON JH.JobNum = SP.JobNum
ORDER BY sp.ReqDate
