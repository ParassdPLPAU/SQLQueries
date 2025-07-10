SELECT Vendor.VendorID, PODetail.PartNum,SUM(PODetail.OrderQty) AS QtyOrdered 
From erp.POHeader 
INNER JOIN erp.PODetail ON 
PODetail.PONUM = POHeader.PONum
INNER JOIN erp.Vendor ON 
Vendor.VendorNum = PODetail.VendorNum
WHERE POHeader.OrderDate > '01/09/2024'
GROUP BY VendorID,PODetail.PartNum
ORDER BY VendorID ASC,PartNum ASC
