SELECT Part.PartNum, Part.PartDescription,Part.TypeCode,Part.ProdCode,PartRev.RevisionNum,Approved,ApprovedDate,ApprovedBy,EffectiveDate,
StdLaborCost,StdBurdenCost,StdMaterialCost,StdSubContCost,StdMtlBurCost
FROM erp.Part INNER JOIN erp.PartRev
ON erp.Part.PartNum = erp.PartRev.PartNum
AND Part.Inactive = 0 INNER JOIN erp.PartCost
ON erp.PartCost.PartNum = erp.Part.PartNum
WHERE Part.ProdCode LIKE 'H%'
ORDER BY PartNum ASC

SELECT TOP(100) * FROM erp.part