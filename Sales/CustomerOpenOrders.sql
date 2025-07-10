select 
    [OrderHed].[OrderNum] as [OrderHed_OrderNum],
    [OrderHed].[PONum] as [OrderHed_PONum],
    [OrderDtl].[OrderLine] as [OrderDtl_POLine],
    [CustCnt].[Name] as [CustCnt_Name],
    [CustCnt].[City] as [CustCnt_City],
    [OrderDtl].[XPartNum] as [OrderDtl_XPartNum],
    [OrderDtl].[PartNum] as [OrderDtl_PartNum],
    [OrderDtl].[LineDesc] as [OrderDtl_LineDesc],
    [OrderDtl].[SellingQuantity] as [OrderDtl_SellingQuantity],
    [OrderDtl].[SalesUM] as [OrderDtl_SalesUM],
    [OrderHed].[OrderDate] as [OrderHed_OrderDate],
    [OrderDtl].[RequestDate] as [OrderDtl_RequestDate],
    [OrderHed].[NeedByDate] as [OrderHed_NeedByDate]
from Erp.Customer as Customer
inner join Erp.OrderHed as OrderHed on 
    Customer.Company = OrderHed.Company
    and Customer.CustNum = OrderHed.BTCustNum
    and ( OrderHed.OpenOrder = 1  )
inner join Erp.OrderDtl as OrderDtl on 
    OrderHed.Company = OrderDtl.Company
    and OrderHed.OrderNum = OrderDtl.OrderNum
    and ( OrderDtl.OpenLine = 1  )
inner join Erp.CustCnt as CustCnt on 
    OrderHed.Company = CustCnt.Company
    and OrderHed.PrcConNum = CustCnt.ConNum
    and OrderHed.CustNum = CustCnt.CustNum
	and orderhed.ShipToNum = CustCnt.ShipToNum
WHERE OrderHed.OrderNum = '2350522'
--where (Customer.CustID = 'P_WP')
ORDER BY OrderHed.OrderNum, OrderDtl_POLine

SELECT * FROM Customer WHERE CustID = 'P_PLINK'
SELECT * FROM erp.CustCnt WHERE CustNum = 829 and ConNum = 4
select * from erp.OrderHed where ordernum = 2350522

--New code received from Matt Fenner
select 
    [OrderHed].[OrderNum] as [OrderHed_OrderNum],
    [OrderHed].[PONum] as [OrderHed_PONum],
    [OrderDtl].[OrderLine] as [OrderDtl_POLine],
    [CustCnt].[Name] as [CustCnt_Name],
    [CustCnt].[City] as [CustCnt_City],
    [OrderDtl].[XPartNum] as [OrderDtl_XPartNum],
    [OrderDtl].[PartNum] as [OrderDtl_PartNum],
    [OrderDtl].[LineDesc] as [OrderDtl_LineDesc],
    [OrderDtl].[SellingQuantity] as [OrderDtl_SellingQuantity],
    [OrderDtl].[SalesUM] as [OrderDtl_SalesUM],
    [OrderHed].[OrderDate] as [OrderHed_OrderDate],
    [OrderDtl].[RequestDate] as [OrderDtl_RequestDate],
    [OrderHed].[NeedByDate] as [OrderHed_NeedByDate]
from Erp.Customer as Customer
inner join Erp.OrderHed as OrderHed on 
    Customer.Company = OrderHed.Company
    and Customer.CustNum = OrderHed.BTCustNum
    and ( OrderHed.OpenOrder = 1  )
inner join Erp.OrderDtl as OrderDtl on 
    OrderHed.Company = OrderDtl.Company
    and OrderHed.OrderNum = OrderDtl.OrderNum
    and ( OrderDtl.OpenLine = 1  )
inner join Erp.CustCnt as CustCnt on 
    --OrderHed.Company = CustCnt.Company
    --and OrderHed.PrcConNum = CustCnt.ConNum
    --and OrderHed.CustNum = CustCnt.CustNum
    --and orderhed.ShipToNum = CustCnt.ShipToNum
                OrderHed.Company = CustCnt.Company
                and OrderHed.CustNum = CustCnt.CustNum 
                and OrderHed.PrcConNum = CustCnt.ConNum
                and CustCnt.ShipToNum = ''

--where OrderHed.OrderNum = '2350522'
ORDER BY OrderHed.OrderNum, OrderDtl_POLine
