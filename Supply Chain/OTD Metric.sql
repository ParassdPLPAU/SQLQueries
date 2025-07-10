--OTD Metric

WITH ORDERS AS (
	SELECT C.CustID,H.OrderNum,D.OrderLine,R.OrderRelNum,H.OrderDate,H.PONum,D.PartNum,D.LineDesc,D.IUM,D.XPartNum,D.OrderQty,D.RequestDate,D.NeedByDate,D.Promise_Date_c,R.Company,H.OrderType_c AS 'Project',H.Order_Type2_c AS 'Other',H.Order_Type3_c AS 'Contract'
	FROM OrderHed H
	INNER JOIN Customer C ON C.CustNum = H.CustNum
	LEFT JOIN OrderDtl D ON H.OrderNum = D.OrderNum AND H.Company = D.Company
	LEFT JOIN OrderRel R ON D.OrderNum = R.OrderNum AND D.OrderLine = R.OrderLine AND D.Company = R.Company
	WHERE 
	--OpenLine = 1 AND 
	VoidLine = 0-- AND H.OrderNum = '2346881'
), OTD AS (
SELECT CustID, R.OrderNum, R.OrderLine, R.OrderRelNum, R.OrderDate, R.PONum, R.PartNum, R.LineDesc, R.IUM, R.XPartNum, R.OrderQty, R.RequestDate AS 'ShipBy',R.Promise_Date_c AS 'PromiseDate',
R.NeedByDate AS 'NeedBy',R.Project,R.Contract,R.Other, SD.PackNum,SD.PackLine, ID.InvoiceNum, ID.ShipDate
FROM ORDERS R LEFT JOIN ShipDtl SD
ON R.OrderNum = SD.OrderNum AND 
	R.OrderLine = SD.OrderLine AND
	R.OrderRelNum = SD.OrderRelNum AND
	R.Company = SD.Company
LEFT JOIN erp.InvcDtl ID 
ON ID.PackLine = SD.PackLine AND
	ID.PackNum = SD.PackNum
)


--Check sales kit parts
SELECT * FROM OrderDtl INNER JOIN Part ON Part.PartNum = OrderDtl.PartNum WHERE TypeCode = 'K' AND OpenLine = 1
SELECT * FROM Part WHERE PartNum = 'WRH6612S'


SELECT * FROM ShipDtl SD WHERE SD.OrderNum = '2346881'