SELECT TOP(100) 
    YEAR(payrolldate) AS 'Year', MONTH(payrolldate) AS 'Month',SUM(LaborHrs) AS TotalLaborHours
FROM LaborDtl
WHERE LaborType = 'P'
GROUP BY YEAR(payrolldate), MONTH(payrolldate)
ORDER BY YEAR(payrolldate) DESC, MONTH(payrolldate) DESC;

WITH BASE AS (
	SELECT 
		SysDate,PT.PartNum,JH.JobNum,TranType,TranQty,JH.ProdQty,JH.QtyCompleted, 
		(JA.TLEProdHours + JA.LLEProdHours) AS 'EstJobProdHours', 
		(JA.TLAProdHours + JA.LLAProdHours) AS 'ActJobProdHours', 
		(JA.TLEProdHours + JA.LLEProdHours)/ProdQty*TranQty AS 'EstProdHrsForStk',
		CASE WHEN QtyCompleted <> 0 THEN
		(JA.TLAProdHours + JA.LLAProdHours)/QtyCompleted*TranQty 
		ELSE 0
		END	AS 'ActProdHrsForStk',
		CASE WHEN QtyCompleted <> 0 THEN
		(JA.TLEBurdenCost+JA.TLELaborCost+JA.TLEMtlBurCost+JA.TLEMaterialCost+JA.TLESubcontractCost)/ProdQty*TranQty 
		ELSE 0
		END AS 'EstCostForStk',
		CASE WHEN QtyCompleted <> 0 THEN
		(JA.TLABurdenCost+JA.TLALaborCost+JA.TLAMaterialBurCost+JA.TLAMaterialCost+JA.TLASubcontractCost)/QtyCompleted*TranQty 
		ELSE 0
		END AS 'ActCostForStk'
	FROM PartTran PT
	INNER JOIN JobHead JH ON
		PT.JobNum = JH.JobNum
	INNER JOIN erp.JobAsmbl JA ON
		PT.JobNum = JA.JobNum
	WHERE trantype = 'MFG-STK' and PT.SysDate >= '01-01-2024'
), OperationHours as (
	select 
		[PartOpr].[PartNum] as PartNum,
		[PartOpr].[RevisionNum] as RevNum,
		(sum(PartOpr.ProdStandard)/60) as TotalEstProdHrs,
		(sum(PartOpr.EstSetHours)) as TotalSetProdHrs
	from Erp.PartOpr as PartOpr
	group by [PartOpr].[PartNum],
		[PartOpr].[RevisionNum]
)
SELECT B.SysDate,B.PartNum,B.JobNum,B.TranType,B.TranQty,B.ProdQty,B.QtyCompleted,OH.TotalEstProdHrs*ProdQty AS 'StdJobProdHours',B.EstJobProdHours,B.ActJobProdHours,OH.TotalEstProdHrs*B.TranQty AS 'StdProdHrsForStk',
B.EstProdHrsForStk,B.ActProdHrsForStk,
CASE WHEN QtyCompleted <> 0 THEN 
(PC.StdBurdenCost + PC.StdLaborCost + PC.StdMaterialCost + PC.StdMtlBurCost + PC.StdSubContCost) * B.TranQty
ELSE 0
END AS 'StdCostForStk',
B.EstCostForStk,B.ActCostForStk
FROM BASE B INNER JOIN OperationHours OH
ON B.PartNum = OH.PartNum 
INNER JOIN erp.PartCost PC ON
PC.PartNum = B.PartNum
where B.EstCostForStk-B.ActCostForStk>10000
ORDER BY B.JobNum desc,B.sysdate desc 

SELECT SUM(JA.TLABurdenCost+JA.TLALaborCost+JA.TLAMtlBurCost+JA.TLAMaterialCost+JA.TLASubcontractCost) FROM erp.JobAsmbl JA WHERE JobComplete = 1 and StartDate>='2024-01-01' and DueDate <= '2024-12-31'


SELECT TOP (100) * FROM erp.PartTran WHERE trantype = 'MFG-STK' order by sysdate desc

SELECT TOP (100) * FROM erp.PartOpDtl where partnum = 'A-A2769-05'
SELECT TOP (100) * FROM erp.PartOpr --where partnum = 'A-A2769-05'
SELECT TOP (100) * FROM erp.PartMtl where PullAsAsm = 1
SELECT TOP(100) * FROM erp.JobASMBL where jobnum = 'J097847' order by duedate desc

SELECT TOP (100) * FROM erp.partdtl order by duedate asc