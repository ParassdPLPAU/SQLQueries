--Check duplicates parts setup as materials in the BoM of a part
SELECT 
    pm1.PartNum, 
    pm1.MtlSeq AS MtlSeq1, 
    pm2.MtlSeq AS MtlSeq2, 
    pm1.MtlPartNum
FROM 
    erp.PartMtl pm1
INNER JOIN 
    erp.PartMtl pm2
ON 
    pm1.PartNum = pm2.PartNum 
    AND pm1.MtlPartNum = pm2.MtlPartNum 
    AND pm1.MtlSeq <> pm2.MtlSeq
INNER JOIN 
    erp.Part p
ON 
    pm1.PartNum = p.PartNum
WHERE 
    p.InActive = 0
ORDER BY 
    pm1.PartNum, pm1.MtlSeq, pm2.MtlSeq;