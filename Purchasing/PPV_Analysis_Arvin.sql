SELECT TOP (1000) [Company]
      ,[EADType]
      ,[DefineBy]
      ,[EarliestApplyDate]
      ,[SysRevID]
      ,[SysRowID]
  FROM [PLP_LIVE].[Erp].[EADType]

SELECT * FROM PORel WHERE DueDate > '2024-11-01' order by duedate desc

WITH COST AS (
	SELECT Part.PartNum,
	CASE 
		WHEN TypeCode = 'P' THEN PartCost.StdMaterialCost
		WHEN TypeCode = 'M' THEN (
			PartCost.StdMaterialCost+
			PartCost.StdLaborCost+
			PartCost.StdBurdenCost+
			PartCost.StdMtlBurCost+
			PartCost.StdSubContCost
		)
	END AS 'Std_Cost' 
	FROM erp.PartCost INNER JOIN
	erp.Part ON 
	PartCost.PartNum = Part.PartNum
)
SELECT
	PD.PONum,
	PR.POLine,
	PR.PORelNum,
	PR.Dropship,
	PC.PartNum,
	PC.Std_Cost,
	PD.UnitCost,
	ROUND(PR.RelQty,2) AS 'RelQty',
	PD.XOrderQty,
	PC.Std_Cost*PR.RelQty AS 'LineStdCost',
	PD.UnitCost*PR.RelQty AS 'LinePOCost',
	CASE 
		WHEN PR.Dropship = 0 THEN
			(PC.Std_Cost*PR.RelQty - PD.UnitCost*PR.RelQty)
		WHEN PR.Dropship = 1 THEN (
			PC1.StdMaterialCost+
			PC1.StdLaborCost+
			PC1.StdBurdenCost+
			PC1.StdMtlBurCost+
			PC1.StdSubContCost
		)
	END AS 'Expected_PPV',
	PR.DueDate
FROM erp.PODetail PD
LEFT JOIN erp.PoRel PR
ON PR.PONum = PD.PONum
AND PR.POLine = PD.POLine
INNER JOIN COST PC
ON PC.PartNum = PD.PartNum
INNER JOIN erp.PartCost PC1
ON PC.PartNum = PC1.PartNum
WHERE PR.DueDate > GETDATE()
AND PR.OpenRelease = 1
order by PR.DueDate DESC;

SELECT * FROM erp.POrel

LEFT JOIN erp.APInvDtl AP
ON AP.PONum = PR.PONum
AND AP.POLine = PR.POLine
AND AP.PORelNum = PR.PORelNum

SELECT * FROM erp.PartCost
Select * from erp.PoREl

