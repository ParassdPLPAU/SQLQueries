--Check how many jobs have been overbooked
SELECT JH.Startdate, JH.PartNum,JP.JobNum, JP.ProdQty,JH.QtyCompleted, JP.ReceivedQty
FROM erp.JobProd JP
INNER JOIN JobHead JH
ON JH.JobNum = JP.JobNum
where JH.prodqty < ReceivedQty  
OR (JH.QtyCompleted-ReceivedQty > 1)   
OR ((JH.QtyCompleted-JH.prodqty) > 1)
AND (JobComplete = 1 AND ReceivedQty = 0)
order by JH.startdate desc

SELECT * FROM erp.InvcDtl where invoicenum = '413190'