SELECT * from Part WHERE Part.Inactive = 0 WHERE TypeCode = 'P'

SELECT PartNum, RevisionNum, SUM(EstSetHours) AS 'Total Setup Hours', SUM(EstProdHours)*250 AS 'Total Production Hours' From erp.PartOpr GROUP BY PartNum, RevisionNum HAVING PartNum = 'A-A4118-14' ORDER BY PartNum 

SELECT PartNum, RevisionNum, SUM(EstSetHours) AS 'Total Setup Hours', SUM(ProdStandard)/60*250 AS 'Total Production Hours' From erp.PartOpr GROUP BY PartNum, RevisionNum HAVING PartNum = 'A-A4118-14' ORDER BY PartNum 

SELECT * From erp.PartOpr WHERE PartNum = 'A-A4118-14' 

SELECT * FROM erp.PartMtl WHERE PartNum = 'CDEA-338-1'

SELECT * FROM erp.Part INNER JOIN erp.PartPlant on erp.PartPlant.PartNum = erp.Part.PartNum

SELECT Part.PartNum,PartDescription,ClassID,IUM,PUM,PurchasingFactor,SalesUM,SellingFactor,MtlBurRate,TypeCode,Part.NonStock,ProdCode,PurComment,Part.CostMethod, MtlAnalysisCode, Constrained, FROM erp.Part INNER JOIN erp.PartPlant on erp.PartPlant.PartNum = erp.Part.PartNum WHERE Part.Inactive = 0 AND PartPlant = 'GLEND'

SELECT ClosedDate,JobCompletionDte,JobNum,PartNum,RevisionNum,ProdQty,IUM,StartDate,StartHour,DueDate,DueHour,ReqDueDate,ProdCode, FROM erp.JobHead WHERE JobClosed = 1

SELECT * FROM erp.JobAsmbl

WITH BASE AS (
	SELECT PartNum, RevisionNum, SUM(EstProdHours) AS 'TtlStdHrs' From erp.PartOpr GROUP BY PartNum, RevisionNum 
)

SELECT StartDate,DueDate,JobNum,JobAsmbl.PartNum,Description,RequiredQty,ROUND((TtlStdHrs*RequiredQty),2) AS 'EstimatedStdHrs',TLAProdHours AS 'ActualProdHrs',TLEProdHours AS 'EstimatedProdHrs' FROM erp.JobAsmbl 
INNER JOIN BASE
ON BASE.PartNum = JobAsmbl.PartNum
WHERE StartDate >= '01.01.2023' AND JobNum NOT LIKE 'U%'
ORDER BY StartDate

--Check operations with Operations UoM set as something other than minutes per piece
WITH BASE AS (
SELECT COUNT(*) AS 'Count',PartNum,StdFormat FROM erp.PartOpr GROUP BY PartNum,StdFormat
), BASE_2 AS (
SELECT PartNum from Part WHERE Part.InActive = 0
)
SELECT COUNT(*),StdFormat FROM BASE INNER JOIN BASE_2 ON BASE_2.PARTNUM = BASE.PartNum GROUP BY StdFormat

--Check last MRP run
SELECT Plant,PartPlant.PartNum,Part.TypeCode,PartPlant.MRPLastRunDate,PartPlant.MRPLastRunTime, PartPlant.ProcessMRP 
FROM PartPlant 
INNER JOIN Part ON Part.PartNum = PartPlant.PartNum 
WHERE Part.Inactive = 0 AND Plant = 'GLENDN' AND ProcessMRP = 1 
ORDER BY MRPLastRunDate, MRPLastRunTime ASC 

--Check materials with Material Std Cost as 0 
WITH BASE AS (
SELECT (PartCost.StdMaterialCost+StdLaborCost+StdMtlBurCost+StdSubContCost+StdBurdenCost) AS 'TotalStdCost',
PartCost.StdMaterialCost,PartCost.StdLaborCost,PartCost.StdMtlBurCost,PartCost.StdSubContCost,PartCost.StdBurdenCost,PartCost.LastMaterialCost, Part.PartNum 
FROM erp.PartCost 
INNER JOIN Part 
ON Part.PartNum = PartCost.PartNum
),
BASE2 AS(
	SELECT Part.PartNum,DemandQty 
	From erp.Part 
	INNER JOIN erp.PartWhse 
	ON PartWhse.PartNum = Part.PartNum 
	WHERE Inactive = 0 AND WarehouseCode = '190' --AND Part.TypeCode = 'P'--AND DemandQty <> 0
)

SELECT erp.Part.PartNum,erp.Part.TypeCode,erp.PartCost.StdSubContCost
FROM erp.PartCost INNER JOIN erp.Part 
ON erp.Part.Partnum = erp.PartCost.PartNum
WHERE erp.Part.Inactive = 0 AND
--erp.Part.TypeCode = 'P' AND
erp.PartCost.StdSubContCost <> 0

Select * from part
--SELECT BASE.PartNum, BASE.StdLaborCost,BASE.TotalStdCost,BASE2.DemandQty FROM BASE INNER JOIN BASE2 ON BASE.PartNum = BASE2.PartNum WHERE StdLaborCost <> 0-- OR TotalStdCost = 0
SELECT BASE.PartNum, BASE.StdMaterialCost,BASE.LastMaterialCost,BASE2.DemandQty FROM BASE INNER JOIN BASE2 ON BASE.PartNum = BASE2.PartNum WHERE BASE.StdMaterialCost = 0 OR TotalStdCost = 0
SELECT * FROM erp.PartWhse where WarehouseCode = '190'
SELECT * FROM erp.PartCost

SELECT * FROM erp.PartTran INNER JOIN erp.PartTran 
SELECT * FROM erp.PartTran_UD

SELECT TOP(100) SUM(LaborHrs),SUM(BurdenHrs),SUM(EarnedHrs) from erp.LaborDtl Order by payrolldate desc

-- Arvin #1 All active parts with standard costs
SELECT Part.PartNum, (PartCost.StdMaterialCost+StdLaborCost+StdMtlBurCost+StdSubContCost+StdBurdenCost) AS 'TotalStdCost',
PartCost.StdMaterialCost,PartCost.StdLaborCost,PartCost.StdMtlBurCost,PartCost.StdSubContCost,PartCost.StdBurdenCost
FROM erp.PartCost 
INNER JOIN Part 
ON Part.PartNum = PartCost.PartNum
WHERE Part.Inactive = 0

--Expected PPV vs Actual PPV
WITH EXPECTED AS (
	SELECT H.VendorNum,OrderDate,H.PONum,D.POLine,D.PartNum,D.PUM,D.IUM,D.UnitCost,D.OrderQty, (D.UnitCost * D.OrderQty) AS 'TotalLineValue'FROM POHeader H INNER JOIN
	erp.PODetail D ON H.PONum = D.PONum
	AND H.Company = D.Company
	WHERE H.VoidOrder = 0
)
SELECT * FROM EXPECTED

SELECT * FROM POHeader
SELECT * FROM erp.PODetail