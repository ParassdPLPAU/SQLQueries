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
)