--DMT to close all firm jobs related to AEM
SELECT PP.Company,PP.Plant,JobNum,1 AS 'QuantityContinue',PP.PartNum,'TRUE' AS JobClosed, 'TRUE' AS JobComplete, 
CASE WHEN JobCompletionDate IS NOT NULL THEN JobCompletionDate ELSE CAST(GETDATE()-1 AS DATE) 
END AS 'JobCompletionDate',
CAST(GETDATE() AS DATE) AS 'ClosedDate'  FROM erp.JobHead JH
INNER JOIN erp.PartPlant PP ON PP.PartNum = JH.PartNum
where jobfirm = 1 and jobclosed = 0 
and pp.personid LIKE '%AEM%'

--Identify all parts to be set as pull as assembly
SELECT PW.PartNum, PW.OnHandQty,WarehouseCode
FROM erp.PartWhse PW 
INNER JOIN erp.PartPlant PP ON PP.PartNum = PW.PartNum
AND pp.personid LIKE '%AEM%' and PP.SourceType = 'M'
WHERE PW.OnHandQty <> 0 order by OnHandQty desc

--Update all BoM records to pull as assembly
SELECT PP.Company,Plant,PM.PartNum,RevisionNum,
'DavidB' AS ECOGroupID,
MtlSeq,
MtlPartNum,
1 AS PullAsAsm
FROM erp.PartMtl PM 
INNER JOIN erp.PartPlant PP ON PP.PartNum = PM.MtlPartNum
WHERE MtlPartNum IN (
		SELECT PW.PartNum
		FROM erp.PartWhse PW 
		INNER JOIN erp.PartPlant PP ON PP.PartNum = PW.PartNum
		AND pp.personid LIKE '%AEM%' and PP.SourceType = 'M'
		WHERE PW.OnHandQty <> 0
)

--Update AutoconsumeStock
SELECT PP.Company,Plant,PP.PartNum,
1 AS AutoConsumeStock
FROM erp.PartPlant PP
WHERE PartNum IN (
		SELECT PW.PartNum
		FROM erp.PartWhse PW 
		INNER JOIN erp.PartPlant PP ON PP.PartNum = PW.PartNum
		AND pp.personid LIKE '%AEM%' and PP.SourceType = 'M'
		WHERE PW.OnHandQty <> 0
)

--Close sales orders before a certain date
SELECT DISTINCT ORL.Company,ORL.OrderNum,ORL.OrderLine,ORL.OrderRelNum,ORL.PartNum, --ORL.OpenRelease,
--C.CustID AS CustomerCustID, 
0 AS OpenRelease
FROM erp.OrderRel ORL 
INNER JOIN erp.PartPlant PP ON PP.PartNum = ORL.PartNum
INNER JOIN erp.Customer C ON C.CustNum = ORL.ShipToCustNum
--INNER JOIN erp.OrderHed OH ON OH.OrderNum = ORL.OrderNum
WHERE ReqDate < '2025-10-31' AND PP.PersonID LIKE '%AEM%' AND PP.SourceType = 'M' AND OpenRelease = 1
ORDER BY OrderNum, OrderLine