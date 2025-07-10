--SOH Data
SELECT PP.Plant,W.WarehouseCode,W.PartNum, P.PartDescription, P.TypeCode,
-- (C.StdBurdenCost+C.StdLaborCost+C.StdMaterialCost+C.StdMtlBurCost+C.StdSubContCost) AS 'TotalStdCostPerUnit', 
W.OnHandQty, PP.SafetyQty
--,W.OnHandQty*(C.StdBurdenCost+C.StdLaborCost+C.StdMaterialCost+C.StdMtlBurCost+C.StdSubContCost) AS 'TotalStdCostOnHand'
FROM erp.PartWhse W 
INNER JOIN erp.PartCost C
ON C.PartNum = W.PartNum
INNER JOIN erp.Part P
ON C.PartNum = P.PartNum
INNER JOIN erp.PartPlant PP
ON W.PartNum = PP.PartNum
--AND W.Plant = PP.Plant
WHERE P.InActive = 0
AND warehouseCode = '190'
AND (W.OnHandQty <> 0
OR PP.SafetyQty <> 0
)
ORDER BY PP.PartNum 

SELECT * FROM erp.PartPlant
SELECT * FROM erp.PartWhse
SELECT * FROM erp.Plant
SELECT * from erp.PartBin order by partnum asc

--SO Data
SELECT OrderNum, OpenOrder,VoidOrder,Customer.CustID,OrderDate,EntryPerson,TotalCharges,TotalLines,TotalReleases,TotalShipped,TotalInvoiced,TotalCommLines
FROM OrderHed
INNER JOIN Customer
ON Customer.CustNum = Orderhed.CustNum
WHERE OpenOrder = 1

SELECT Promise_Date_c from dbo.OrderDtl
--PO Data
SELECT PONum, OpenOrder,VoidOrder,OrderHeld,VendorNum,OrderDate,BuyerID,EntryPerson,ApprovalStatus,TotalCharges
FROM POHeader
WHERE OpenOrder = 1

--PO Lines
SELECT D.PONum, OpenRelease, VoidRelease, D.POLine, PartNum, OrderQty, R.DueDate 
FROM erp.PORel R
INNER JOIN erp.PODetail D
ON R.PONum = D.PONUM AND R.POLine = D.POLine and R.Company = D.Company
WHERE OpenLine = 1

SELECT * FROM erp.PODetail
SELECT * FROM erp.PORel

SELECT * FROM PartTran 

--Jobs Data
SELECT JobNum,PartNum,RevisionNum,JobComplete,JobFirm,JobReleased,JobHeld,SchedStatus,ProdQty,TravelerLastPrinted,QtyCompleted,JobType,
CreateDate,CreatedBy,DueDate,ReqDueDate
FROM erp.JobHead
WHERE JobClosed = 0
order by duedate asc

--Check transfer orders
SELECT * FROM erp.TFOrdHed where openorder = 1
SELECT * FROM erp.TFOrdDtl where TFOrdDtl.OpenLine = 1

--UDTimePhaseMOQBoxQty
SELECT Plant,PartNum,MOQ_c,BoxQty_c 
FROM dbo.PartPlant
WHERE MOQ_c <> 0
OR BoxQty_c <> 0

SELECT * FROM ShipDtl where OrderNum = '2357642'
SELECT * FROM erp.ShipHead where PackNum = '104038'