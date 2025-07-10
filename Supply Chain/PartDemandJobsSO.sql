--Part usage in 2024
With JobDemand AS (
	SELECT PartNum,SUM(TranQty) AS 'TotalJobs',COUNT(TranQty) AS 'TotalCountJobs' FROM erp.PartTran where trantype = 'STK-MTL'
	AND TranDate <= '2024-12-31'
	AND	TranDate >= '2024-01-01'
	GROUP BY PartNum 
), OrderDemand AS ( 
	SELECT 
		ORL.PartNum,
		SUM(OurStockShippedQty) AS 'TotalOrders',
		COUNT(OurStockShippedQty) AS 'TotalCountOrders'
	FROM 
		erp.OrderDtl OD 
	LEFT JOIN erp.OrderRel ORL 
		ON OD.OrderNum = ORL.OrderNum 
		AND OD.OrderLine = ORL.OrderLine 
	WHERE RequestDate <= '2024-12-31'
		AND RequestDate >= '2024-01-01'
	GROUP BY ORL.PartNum 
	HAVING SUM(OurStockShippedQty) <> 0
	--SELECT OD.OrderNum,OD.OrderLine,OrderRelNum,ORL.PartNum,OrderQty,RequestDate,ReqDate,OD.NeedByDate,ORL.NeedByDate,ORL.OurStockQty,ORL.OurStockShippedQty
	--FROM erp.OrderDtl OD LEFT JOIN erp.OrderRel ORL ON OD.OrderNum = ORL.OrderNum AND OD.OrderLine = ORL.OrderLine order by OD.ordernum desc, OD.orderline asc, ORL.OrderRelNum
),BASE_1 AS (
	SELECT 
    DISTINCT COALESCE(JobDemand.PartNum, OrderDemand.PartNum) AS PartNum,
    COALESCE(JobDemand.TotalJobs, 0) AS TotalJobDemand,
    COALESCE(OrderDemand.TotalOrders, 0) AS TotalOrderDemand,
    COALESCE(JobDemand.TotalJobs, 0) + COALESCE(OrderDemand.TotalOrders, 0) AS 'TotalDemand'
FROM JobDemand
FULL OUTER JOIN OrderDemand ON JobDemand.PartNum = OrderDemand.PartNum
)
SELECT BASE_1.PartNum,TotalJobDemand,TotalOrderDemand,TotalDemand,PartDescription,ClassID,TypeCode,ProdCode 
FROM BASE_1 INNER JOIN Part ON Part.PartNum = BASE_1.PartNum --WHERE Part.InActive = 0 
--WHERE Part.PartNum = 'GRS-500-2'
order by totaldemand desc

--Part demand on open orders and jobs
With OpenJobDemand AS (
	SELECT PartNum,SUM(RequiredQty-IssuedQty) AS 'TotalJobs'
	FROM 
		erp.JobMtl
	WHERE IssuedComplete = 0
	GROUP BY PartNum
), OpenOrderDemand AS (
	SELECT 
		PartNum,
		SUM(OurStockQty-OurStockShippedQty) AS 'TotalOrders'
	FROM
		erp.OrderRel
	WHERE OpenRelease = 1
	GROUP BY PartNum
),BASE_1 AS (
	SELECT 
    DISTINCT COALESCE(OpenJobDemand.PartNum, OpenOrderDemand.PartNum) AS PartNum,
    COALESCE(OpenJobDemand.TotalJobs, 0) AS TotalJobDemand,
    COALESCE(OpenOrderDemand.TotalOrders, 0) AS TotalOrderDemand,
    COALESCE(OpenJobDemand.TotalJobs, 0) + COALESCE(OpenOrderDemand.TotalOrders, 0) AS 'TotalDemand'
FROM OpenJobDemand
FULL OUTER JOIN OpenOrderDemand ON OpenJobDemand.PartNum = OpenOrderDemand.PartNum
)
SELECT BASE_1.PartNum,TotalJobDemand,TotalOrderDemand,TotalDemand,PartDescription,ClassID,TypeCode,ProdCode 
FROM BASE_1 INNER JOIN Part ON Part.PartNum = BASE_1.PartNum --WHERE Part.InActive = 0 
order by totaldemand desc