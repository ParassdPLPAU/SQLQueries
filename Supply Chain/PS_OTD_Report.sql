WITH AllOverDueOrders AS(
	SELECT * FROM dbo.OrderDtl WHERE Promise_Date_c <= GETDATE() AND Promise_Date_c >= '01-01-2024'
	AND VOIDLine = 0
),AllOverDueReleases_WODropShip AS (
	SELECT AODO.PartNum,AODO.OrderQty,AODO.Promise_Date_c,AODO.RequestDate,AODO.NeedByDate,AODO.OrderNum,
	AODO.OrderLine,ORL.OrderRelNum
	FROM AllOverDueOrders AODO
	LEFT JOIN erp.OrderRel ORL ON AODO.OrderNum = ORL.OrderNum AND AODO.OrderLine = ORL.OrderLine 
	WHERE Dropship = 0
),AllOverDueReleases_DropShip AS (
	SELECT AODO.PartNum,AODO.OrderQty,AODO.Promise_Date_c,AODO.RequestDate,AODO.NeedByDate,AODO.OrderNum,
	AODO.OrderLine,ORL.OrderRelNum
	FROM AllOverDueOrders AODO
	LEFT JOIN erp.OrderRel ORL ON AODO.OrderNum = ORL.OrderNum AND AODO.OrderLine = ORL.OrderLine 
	WHERE Dropship = 1
),AllDropShippedLines AS (
	SELECT AODR.*,DSD.PackSlip,DSD.PackLine,DSD.OurQty,DSD.ReceiptDate,APH.InvoiceDate 
	FROM AllOverDueReleases_DropShip AODR
	LEFT JOIN Erp.Dropshipdtl DSD ON AODR.OrderNum = DSD.OrderNum AND AODR.OrderLine = DSD.OrderLine
	AND AODR.OrderRelNum = DSD.OrderRelNum
	LEFT JOIN erp.APInvDtl AP ON AP.PackSlip = DSD.PackSlip AND AP.PackLine = DSD.PackLine 
	AND DSD.APInvoiceNum = AP.InvoiceNum
	LEFT JOIN erp.APInvHed APH ON AP.InvoiceNum = APH.InvoiceNum
),AllNonDropShippedLines AS (
	SELECT AODR.*,SD.PackNum,PackLine,OurInventoryShipQty,SH.ShipDate FROM AllOverDueReleases_DropShip AODR
	LEFT JOIN dbo.ShipDtl SD ON AODR.OrderNum = SD.OrderNum AND AODR.OrderLine = SD.OrderLine
	AND AODR.OrderRelNum = SD.OrderRelNum
	LEFT JOIN erp.ShipHead SH ON SD.PackNum = SH.PackNum
),OTD_NonDropShipLines AS (
	SELECT OrderNum,OrderLine,SUM(OurInventoryShipQty) AS 'TotalShippedQty',OrderQty FROM AllNonDropShippedLines 
	WHERE ShipDate <= Promise_Date_c
	GROUP BY OrderNum,OrderLine,OrderQty
	HAVING SUM(OurInventoryShipQty) >= OrderQty
),OTD_DropShipLines AS (
	SELECT OrderNum,OrderLine,SUM(OurQty) AS 'TotalDropShippedQty',OrderQty FROM AllDropShippedLines
	--WHERE InvoiceDate <= Promise_Date_c
	GROUP BY OrderNum,OrderLine,OrderQty
	HAVING SUM(OurQty) >= OrderQty
)
SELECT * FROM AllDropShippedLines