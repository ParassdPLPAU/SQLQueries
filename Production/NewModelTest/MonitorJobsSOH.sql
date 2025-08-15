--Identify Jobs in AEM Assembly that are MTS along with their total demand and on-hand quantities
WITH TotalDemand AS (
	SELECT PP.PartNum, SUM(PD.Quantity) AS TotalDemandQty
	FROM erp.PartPlant PP
	INNER JOIN erp.PartDtl PD ON PD.PartNum = PP.PartNum AND PP.PersonID LIKE '%AEM%' AND PP.Plant = 'GLENDN'
	AND PP.SourceType = 'M' AND PD.RequirementFlag = 1
	GROUP BY PP.PartNum
),OnHandQty AS (
	SELECT PW.PartNum, SUM(PW.OnHandQty) AS OnHandQty
	FROM erp.PartWhse PW
	INNER JOIN erp.PartPlant PP ON PW.PartNum = PP.PartNum AND PP.Plant = 'GLENDN' AND PP.PersonID LIKE '%AEM%'
	GROUP BY PW.PartNum
)
SELECT JH.JobNum, JH.PartNum,JP.ProdQty,JP.WarehouseCode,PP.NonStock, TD.TotalDemandQty, PW.OnHandQty 
FROM erp.JobHead JH
INNER JOIN erp.JobProd JP ON JP.Company = JH.Company AND JP.JobNum = JH.JobNum AND JH.JobClosed = 0 AND WarehouseCode = 190
INNER JOIN erp.PartPlant PP ON JH.PartNum = PP.PartNum AND PP.Plant = 'GLENDN' AND PP.PersonID LIKE '%AEM%' 
LEFT JOIN TotalDemand TD ON TD.PartNum = JH.PartNum
LEFT JOIN OnHandQty PW ON JH.PartNum = PW.PartNum

--Identify Mfg SOH parts with AEM Assembly as Bin Location 
SELECT PB.PartNum,PB.BinNum,PB.OnHandQty FROM erp.PartBin PB
LEFT JOIN erp.PartWhse PW ON PB.Company = PW.Company 
AND PB.PartNum = PW.PartNum
AND PB.WarehouseCode = PW.WarehouseCode
AND PW.WarehouseCode = 190
LEFT JOIN erp.PartPlant PP ON PP.PartNum = PB.PartNum AND PP.Plant = 'GLENDN' 
WHERE PP.PersonID LIKE '%AEM%' And BinNum LIKE '%AEM%' AND SourceType = 'M'
order by partnum