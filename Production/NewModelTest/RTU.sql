SELECT CustID,OH.OrderNum,OD.OrderLine,OrderRelNum, OH.PONum,ORL.PartNum,OD.OrderQty,OD.DocUnitPrice,OH.CurrencyCode,OrderDate,ORL.ReqDate
FROM erp.OrderHed OH
LEFT JOIN erp.OrderDtl OD ON OD.OrderNum = OH.OrderNum
LEFT JOIN OrderRel ORL ON ORL.OrderNum = OH.OrderNum AND ORL.OrderLine = OD.OrderLine
INNER JOIN erp.Customer ON OH.CustNum = Customer.CustNum
WHERE VoidRelease = 0
AND CustID = 'P_SECUREJV'

--and OH.ordernum = 2337883

SELECT * FROM erp.ResourceTimeUsed where resourceGrpID LIKE '%aem%' AND JOBNUM LIKE'U%1128'
and whatif = 0 order by startdate asc

SELECT * FROM erp.cal