--SO Expedite Open and Closed orders report for Adam
SELECT TOP(100) * FROM dbo.OrderHed --WHERE Company <> 'AU6101'--OrderNum = 186399 
SELECT TOP(100) * FROM dbo.OrderDtl WHERE OrderNum = '2354013' 
SELECT TOP(100) * FROM erp.OrderRel WHERE OrderNum = '2357451' --OrderNum = 186399
SELECT * FROM erp.InvcDtl;
SELECT * FROM dbo.OrderRel WHERE OpenOrder = 1

--Current Open Order Lines Report
WITH ORDERS AS (
	SELECT C.CustID,H.OrderNum,D.OrderLine,R.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OrderQty,D.RequestDate,D.NeedByDate,R.Company,H.OrderType_c AS 'Project',H.Order_Type2_c AS 'Other',H.Order_Type3_c AS 'Contract'
	FROM OrderHed H
	INNER JOIN Customer C ON C.CustNum = H.CustNum
	LEFT JOIN OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
	WHERE 
	--OpenLine = 1 AND 
	VoidLine = 0-- AND H.OrderNum = '2346881'
)
SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, R.RequestDate AS 'ShipBy',R.NeedByDate AS 'NeedBy',R.Project,R.Contract,R.Other, SD.PackNum,SD.PackLine, ID.InvoiceNum, ID.ShipDate
FROM ORDERS R LEFT JOIN ShipDtl SD
ON R.OrderNum = SD.OrderNum AND 
	R.OrderLine = SD.OrderLine AND
	R.OrderRelNum = SD.OrderRelNum AND
	R.Company = SD.Company
LEFT JOIN erp.InvcDtl ID 
ON ID.PackLine = SD.PackLine AND
	ID.PackNum = SD.PackNum

SELECT * FROM ShipDtl SD WHERE SD.OrderNum = '2346881'



--Current Closed Order Lines Report
WITH ORDERS AS (
	SELECT C.CustID,H.OrderNum,D.OrderLine,R.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OrderQty,D.RequestDate,D.NeedByDate,R.Company
	FROM OrderHed H
	INNER JOIN Customer C ON C.CustNum = H.CustNum
	LEFT JOIN OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
	WHERE OpenLine = 0 AND VoidLine = 0 AND CustID = 'P_WP' AND (YEAR(H.OrderDate) = YEAR(GETDATE()))
)
SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, R.RequestDate AS 'ShipBy',R.NeedByDate AS 'NeedBy', SD.PackNum,SD.PackLine, ID.InvoiceNum, ID.ShipDate
FROM ORDERS R LEFT JOIN ShipDtl SD
ON R.OrderNum = SD.OrderNum AND 
	R.OrderLine = SD.OrderLine AND
	R.OrderRelNum = SD.OrderRelNum AND
	R.Company = SD.Company
LEFT JOIN erp.InvcDtl ID 
ON ID.PackLine = SD.PackLine AND
	ID.PackNum = SD.PackNum
	ORDER BY OrderNum,OrderLine,OrderRelNum


SELECT * FROM erp.

SELECT * FROM erp.InvcDtl ID
SELECT * FROM ShipDtl
SELECT PackNum, PackLine, OurInventoryShipQty FROM ShipDtl

--Pull sales order line details to calculate DIFOT (done for the interns)
SELECT C.CustID,H.OrderNum,D.OrderLine,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.SalesUM,D.RevisionNum,D.UnitPrice,
D.OrderQty,D.Promise_Date_c,SellingQuantity,D.RequestDate,D.ShipByDate,D.NeedByDate,H.OrderType_c AS 'Project',H.Order_Type3_c AS 'Contract', H.Order_Type2_c AS 'Other'
FROM OrderHed H
	INNER JOIN Customer C ON C.CustNum = H.CustNum
	LEFT JOIN OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	WHERE OrderDate >= '01-07-2021' AND 
	D.VoidLine = 0 AND
	PartNum IS NOT NULL

SELECT * from erp.CCDtl

select * from dbo.UD01 ORDER BY Date01 DESC

Select * from erp.OrderRel WHERE DropShip = 1

Select * from erp.DropShipDtl

--Query to pull dropshipment order detail lines, fields below for matching
--SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, 
--R.RequestDate AS 'ShipBy',R.NeedByDate AS 'NeedBy', SD.PackNum,SD.PackLine, ID.InvoiceNum, ID.ShipDate
SELECT C.CustID, D.OrderNum, D.OrderLine, D.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OurQty,
DTL.RequestDate AS 'ShipBy',DTL.NeedByDate AS 'NeedBy',D.PackSlip,D.PackLine,D.ARInvoiceNum,D.ReceiptDate AS 'ShipDate'
from erp.DropShipDtl D
INNER JOIN OrderHed H ON H.OrderNum = D.OrderNum AND H.Company = D.Company
INNER JOIN Customer C ON C.CustNum = H.CustNum
LEFT JOIN OrderDtl DTL ON DTL.OrderNum = D.OrderNum AND DTL.OrderLine = D.OrderLine 
LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.OrderRelNum=R.OrderRelNum AND D.Company = R.Company
ORDER BY ShipBy DESC

--All orders including dropshipments
--Current Open Order Lines Report joined with dispatches done through customer shipment entry screen
WITH ORDERS AS (
	SELECT C.CustID,H.OrderNum,D.OrderLine,R.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OrderQty,R.DropShip,D.RequestDate,D.NeedByDate,R.Company,H.OrderType_c AS 'Project',H.Order_Type2_c AS 'Other',H.Order_Type3_c AS 'Contract'
	FROM OrderHed H
	INNER JOIN Customer C ON C.CustNum = H.CustNum
	LEFT JOIN OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
	WHERE 
	--OpenLine = 1 AND 
	VoidLine = 0-- AND H.OrderNum = '2346881'
), 
--
BASE AS(
SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, R.RequestDate AS 'ShipBy',R.NeedByDate AS 'NeedBy',
R.Project,R.Contract,R.Other, cast(SD.PackNum as varchar) AS 'PackSlip',SD.PackLine, ID.InvoiceNum, ID.ShipDate
FROM ORDERS R LEFT JOIN ShipDtl SD
ON R.OrderNum = SD.OrderNum AND 
	R.OrderLine = SD.OrderLine AND
	R.OrderRelNum = SD.OrderRelNum AND
	R.Company = SD.Company
LEFT JOIN erp.InvcDtl ID 
ON ID.PackLine = SD.PackLine AND
	ID.PackNum = SD.PackNum
	--WHERE R.DropShip = 1 AND SD.PackNum IS NULL) SELECT * FROM BASE

--WHERE R.OrderNum = '2359111'--) SELECT * FROM BASE
--EXCEPT 
--SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, R.RequestDate AS 'ShipBy',R.NeedByDate AS 'NeedBy',
--R.Project,R.Contract,R.Other, cast(SD.PackNum as varchar) AS 'PackSlip',SD.PackLine, ID.InvoiceNum, ID.ShipDate
--FROM ORDERS R LEFT JOIN ShipDtl SD
--ON R.OrderNum = SD.OrderNum AND 
--	R.OrderLine = SD.OrderLine AND
--	R.OrderRelNum = SD.OrderRelNum AND
--	R.Company = SD.Company
--LEFT JOIN erp.InvcDtl ID 
--ON ID.PackLine = SD.PackLine AND
--	ID.PackNum = SD.PackNum
--WHERE R.DropShip = 1 AND SD.PackNum IS NULL--) SELECT * FROM BASE
UNION
SELECT C.CustID, D.OrderNum, D.OrderLine, D.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OurQty,
DTL.RequestDate AS 'ShipBy',DTL.NeedByDate AS 'NeedBy',H.OrderType_c AS 'Project',H.Order_Type3_c AS 'Contract',H.Order_Type2_c AS 'Other',
cast(D.PackSlip as varchar) AS 'PackSlip',D.PackLine,D.ARInvoiceNum,D.ReceiptDate AS 'ShipDate'
from erp.DropShipDtl D
INNER JOIN OrderHed H ON H.OrderNum = D.OrderNum AND H.Company = D.Company
INNER JOIN Customer C ON C.CustNum = H.CustNum
LEFT JOIN OrderDtl DTL ON DTL.OrderNum = D.OrderNum AND DTL.OrderLine = D.OrderLine 
LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.OrderRelNum=R.OrderRelNum AND D.Company = R.Company
--WHERE D.OrderNum = '2359111'
)
SELECT * FROM BASE ORDER BY OrderNum DESC, OrderLine ASC	

--Optimised by chatGPT need to vet
WITH ORDERS AS (
    SELECT 
        C.CustID, H.OrderNum, D.OrderLine, R.OrderRelNum, 
        H.OrderDate, H.PONum, D.PartNum, D.LineDesc, 
        D.IUM, D.XPartNum, D.OrderQty, R.DropShip, 
        D.RequestDate, D.NeedByDate, R.Company, 
        H.OrderType_c AS 'Project', 
        H.Order_Type2_c AS 'Other', 
        H.Order_Type3_c AS 'Contract'
    FROM 
        OrderHed H
    INNER JOIN 
        Customer C ON C.CustNum = H.CustNum
    LEFT JOIN 
        OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
    LEFT JOIN 
        OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
    WHERE 
        VoidLine = 0
),
SHIP AS (
    SELECT 
        R.CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, 
        R.OrderDate, R.PONum, R.PartNum, R.LineDesc, 
        R.IUM, R.XPartNum, R.OrderQty, 
        R.RequestDate AS 'ShipBy', R.NeedByDate AS 'NeedBy', 
        R.Project, R.Contract, R.Other, 
        CAST(SD.PackNum AS varchar) AS 'PackSlip', 
        SD.PackLine, ID.InvoiceNum, ID.ShipDate
    FROM 
        ORDERS R 
    LEFT JOIN 
        ShipDtl SD ON R.OrderNum = SD.OrderNum AND R.OrderLine = SD.OrderLine AND R.OrderRelNum = SD.OrderRelNum AND R.Company = SD.Company
    LEFT JOIN 
        erp.InvcDtl ID ON ID.PackLine = SD.PackLine AND ID.PackNum = SD.PackNum
    WHERE 
        R.DropShip = 0 OR SD.PackNum IS NOT NULL
)
SELECT * 
FROM SHIP
UNION
SELECT 
    C.CustID, D.OrderNum, D.OrderLine, D.OrderRelNum, 
    H.OrderDate, H.PONum, D.PartNum, D.LineDesc, 
    D.IUM, D.XPartNum, D.OurQty, 
    DTL.RequestDate AS 'ShipBy', DTL.NeedByDate AS 'NeedBy', 
    H.OrderType_c AS 'Project', 
    H.Order_Type3_c AS 'Contract', 
    H.Order_Type2_c AS 'Other', 
    CAST(D.PackSlip AS varchar) AS 'PackSlip', 
    D.PackLine, D.ARInvoiceNum, D.ReceiptDate AS 'ShipDate'
FROM 
    erp.DropShipDtl D
INNER JOIN 
    OrderHed H ON H.OrderNum = D.OrderNum AND H.Company = D.Company
INNER JOIN 
    Customer C ON C.CustNum = H.CustNum
LEFT JOIN 
    OrderDtl DTL ON DTL.OrderNum = D.OrderNum AND DTL.OrderLine = D.OrderLine 
LEFT JOIN 
    OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.OrderRelNum = R.OrderRelNum AND D.Company = R.Company
ORDER BY 
    OrderNum DESC, OrderLine ASC;

--Restructuring to be able to add filters
WITH ORDERS AS (
    SELECT 
        C.CustID, H.OrderNum, D.OrderLine, R.OrderRelNum, 
        H.OrderDate, H.PONum, D.PartNum, D.LineDesc, 
        D.IUM, D.XPartNum, D.OrderQty, R.DropShip, 
        D.RequestDate, D.NeedByDate, R.Company, 
        H.OrderType_c AS 'Project', 
        H.Order_Type2_c AS 'Other', 
        H.Order_Type3_c AS 'Contract'
    FROM 
        OrderHed H
    INNER JOIN 
        Customer C ON C.CustNum = H.CustNum
    LEFT JOIN 
        OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
    LEFT JOIN 
        OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
    WHERE 
        VoidLine = 0
),
SHIP AS (
    SELECT 
        R.CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.DropShip,
        R.OrderDate, R.PONum, R.PartNum, R.LineDesc, 
        R.IUM, R.XPartNum, R.OrderQty, 
        R.RequestDate AS 'ShipBy', R.NeedByDate AS 'NeedBy', 
        R.Project, R.Contract, R.Other, 
        CAST(SD.PackNum AS varchar) AS 'PackSlip', 
        SD.PackLine, ID.InvoiceNum, ID.ShipDate
    FROM 
        ORDERS R 
    LEFT JOIN 
        ShipDtl SD ON R.OrderNum = SD.OrderNum AND R.OrderLine = SD.OrderLine AND R.OrderRelNum = SD.OrderRelNum AND R.Company = SD.Company
    LEFT JOIN 
        erp.InvcDtl ID ON ID.PackLine = SD.PackLine AND ID.PackNum = SD.PackNum
    WHERE 
        R.DropShip = 0-- OR SD.PackNum IS NOT NULL
),
DROPSHIP AS (
	SELECT 
    C.CustID, D.OrderNum, D.OrderLine, D.OrderRelNum, R.DropShip,
    H.OrderDate, H.PONum, D.PartNum, D.LineDesc, 
    D.IUM, D.XPartNum, D.OurQty, 
    DTL.RequestDate AS 'ShipBy', DTL.NeedByDate AS 'NeedBy', 
    H.OrderType_c AS 'Project', 
    H.Order_Type3_c AS 'Contract', 
    H.Order_Type2_c AS 'Other', 
    CAST(D.PackSlip AS varchar) AS 'PackSlip', 
    D.PackLine, D.ARInvoiceNum, D.ReceiptDate AS 'ShipDate'
	FROM 
		erp.DropShipDtl D
	INNER JOIN 
		OrderHed H ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	INNER JOIN 
		Customer C ON C.CustNum = H.CustNum
	LEFT JOIN 
		OrderDtl DTL ON DTL.OrderNum = D.OrderNum AND DTL.OrderLine = D.OrderLine 
	LEFT JOIN 
		OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.OrderRelNum = R.OrderRelNum AND D.Company = R.Company
)

SELECT * 
FROM SHIP
WHERE dropship <> 0
UNION 
SELECT * 
FROM DROPSHIP
WHERE dropship <> 0


ORDER BY 
    OrderNum DESC, OrderLine ASC;