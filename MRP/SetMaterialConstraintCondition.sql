/*SELECT PartNum, COUNT(*) AS 'days_out' FROM dbo.StockOuts 
WHERE CalculatedSOHSS > 0 and date_recorded >= GETDATE()-30 GROUP BY PartNum--, Date_Recorded
HAVING COUNT(*) >= 5 order by days_out desc;
*/

--Issue with this query below:
-- Does not record parts with no demand but SOH - should be NC materials
-- Does not account for parts that have demand outside the LT but no demand within LT and has SOH
WITH BASE AS (
SELECT PP.PartNum, MAX(PD.DueDate) AS 'LatestDueDateLT'
FROM erp.PartPlant PP
INNER JOIN erp.partdtl PD
ON PD.PartNum = PP. PartNum
INNER JOIN erp.PartWhse PW
ON PW.PartNum = PP.PartNum
WHERE PP.Plant = 'GLENDN'
AND PW.WarehouseCode = '190'
AND GetDATE() + LeadTime >= PD.DueDate
GROUP BY PP.PartNum,PP.LeadTime
),BASE_2 AS (
SELECT PP.PartNum, 
SUM(PD.Quantity) AS 'Demand'
FROM erp.PartPlant PP
INNER JOIN erp.partdtl PD
ON PD.PartNum = PP. PartNum
INNER JOIN BASE ON
BASE.PartNum = PP.PartNum
INNER JOIN erp.PartWhse PW
ON PW.PartNum = PP.PartNum
WHERE PP.Plant = 'GLENDN'
AND PD.Duedate <= BASE.LatestDueDateLT
AND PW.WarehouseCode = '190'
GROUP BY PP.PartNum
) /*TEST SCRIPT*/
--SELECT PP.PartNum, P.Constrained,  LatestDueDateLT, PW.OnHandQty, Demand, PP.SafetyQty, CASE WHEN ((PW.OnHandQty - BASE_2.Demand) >= PP.SafetyQty) THEN 'Y' ELSE 'N' END as 'Check'
--FROM erp.PartPlant PP
--INNER JOIN erp.PartWhse PW
--ON PP.PartNum = PW.PartNum
--INNER JOIN BASE_2
--ON BASE_2.PartNum = PP. PartNum
--INNER JOIN BASE
--ON BASE.PartNum = PP. PartNum
--INNER JOIN Part P
--ON P.PartNum = PP.PartNum
--WHERE PP.Plant = 'GLENDN'
--AND PW.WarehouseCode = '190'
--AND ((PW.OnHandQty - BASE_2.Demand) >= PP.SafetyQty)
--AND P.Inactive = 0

UPDATE [PLP_PILOT].Erp.Part
SET Constrained = 0 
WHERE PartNum IN (
SELECT PP.PartNum--,P.Constrained,PP.SafetyQty 
FROM erp.PartPlant PP
INNER JOIN erp.PartWhse PW
ON PP.PartNum = PW.PartNum
INNER JOIN BASE_2
ON BASE_2.PartNum = PP. PartNum
INNER JOIN BASE
ON BASE.PartNum = PP. PartNum
INNER JOIN Part P
ON P.PartNum = PP.PartNum
WHERE PP.Plant = 'GLENDN'
AND PW.WarehouseCode = '190'
AND ((PW.OnHandQty - BASE_2.Demand) >= PP.SafetyQty)
AND P.Inactive = 0
)



--Fixed query
--UPDATE [PLP_PILOT].Erp.Part
--SET Constrained = 1
WITH LeadTimeCalc AS ( --Get lead times for all active parts
	SELECT PP.PartNum, PP.Plant,
	CASE
		WHEN P.TypeCode = 'P' THEN PP.LeadTime
		ELSE PP.TotMfgLeadTimeSys
	END AS 'LeadTime'
	FROM PartPlant PP
	INNER JOIN Part P ON PP.PartNum = P.PartNum
	WHERE Plant = 'GLENDN'
	AND P.InActive = 0
),AllPartSOH AS (--GetAllSOH
	SELECT PW.PartNum
	FROM erp.PartWhse PW
	WHERE PW.OnHandQty <> 0
),LatestPartDemandWithinLT AS ( --Get parts with demand that has a due date within the lead time. This will not include any parts that have demand outside the LT.
	SELECT PP.PartNum, PP.LeadTime,MAX(PD.DueDate) AS 'LatestDueDateLT',GetDATE() + LeadTime AS 'dateLT'
	FROM LeadTimeCalc PP
	LEFT JOIN erp.partdtl PD ON PD.PartNum = PP. PartNum
	INNER JOIN erp.PartWhse PW ON PW.PartNum = PP.PartNum
	WHERE PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
	AND (GetDATE() + LeadTime >= PD.DueDate OR PD.DueDate IS NULL)
	GROUP BY PP.PartNum,PP.LeadTime
),TotalDemandWithinLT AS ( --Get total demand of parts within lead time that satisfy the criteria for LatestPartDemandWithinLT. This will not include any parts that have demand outside the LT.
	SELECT PP.PartNum, 
	SUM(PD.Quantity) AS 'Demand'
	FROM erp.PartPlant PP
	INNER JOIN LatestPartDemandWithinLT BASE ON BASE.PartNum = PP.PartNum
	INNER JOIN erp.partdtl PD ON PD.PartNum = PP. PartNum
	INNER JOIN erp.PartWhse PW ON PW.PartNum = PP.PartNum
	WHERE PP.Plant = 'GLENDN'
	AND (PD.Duedate <= BASE.LatestDueDateLT)
	AND PW.WarehouseCode = '190'
	AND PD.RequirementFlag = 1
	GROUP BY PP.PartNum
),Result AS (
SELECT 
	PP.PartNum 
FROM 
	erp.PartPlant PP
INNER JOIN erp.PartWhse PW ON PP.PartNum = PW.PartNum
INNER JOIN TotalDemandWithinLT BASE_2 ON BASE_2.PartNum = PP. PartNum
INNER JOIN Part P ON P.PartNum = PP.PartNum
WHERE PP.Plant = 'GLENDN'
AND PW.WarehouseCode = '190'
AND ((PW.OnHandQty - BASE_2.Demand) >= PP.SafetyQty)
AND PW.OnHandQty <> 0
AND P.Inactive = 0
UNION -- Now get all parts that have SOH but no demand within the LT
SELECT 
	PartNum 
FROM 
	AllPartSOH
WHERE 
	PartNum NOT IN (
		SELECT 
			PartNum 
		FROM 
			TotalDemandWithinLT
		) 
) 

UPDATE [PLP_PILOT].Erp.Part
SET Constrained = 0 
WHERE PartNum IN (SELECT DISTINCT * FROM Result) --order by PartNum)
--SELECT * FROM erp.PartDtl