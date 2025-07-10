select 
	[InvcHead].[InvoiceDate] as [InvcHead_InvoiceDate],
	[InvcHead].[InvoiceNum] as [InvcHead_InvoiceNum],
	[InvcHead].[PONum] as [InvcHead_PONum],
	[InvcHead].[DocInvoiceAmt] as [InvcHead_DocInvoiceAmt],
	[InvcHead].[DocInvoiceBal] as [InvcHead_DocInvoiceBal],
	[InvcHead].[Posted] as [InvcHead_Posted],
	[InvcDtl].[PartNum] as [InvcDtl_PartNum],
	[InvcDtl].[LineDesc] as [InvcDtl_LineDesc],
	[InvcDtl].[UnitPrice] as [InvcDtl_UnitPrice],
	[InvcDtl].[SellingShipQty] as [InvcDtl_SellingShipQty],
	((InvcDtl.UnitPrice* InvcDtl.SellingShipQty)*1.1) as [Calculated_LineTotal],
	[Customer].[CustID] as [Customer_CustID],
	[Customer].[Name] as [Customer_Name],
	[InvcHead].[OrderNum] as [InvcHead_OrderNum]
	,[OrderRel].[PONum] as [OrderRel_PONum],
	[OrderRel].[POLine] as [OrderRel_POLine],
	[OrderRel].[PORelNum] as [OrderRel_PORelNum],
	OrderRel.OrderNum ,
	OrderRel.OrderLine ,
	OrderRel.OrderRelNum 
from Erp.InvcHead as InvcHead
inner join Erp.InvcDtl as InvcDtl on 
	InvcHead.Company = InvcDtl.Company
	and InvcHead.InvoiceNum = InvcDtl.InvoiceNum
inner join Erp.Customer as Customer on 
	InvcDtl.Company = Customer.Company
	and InvcDtl.CustNum = Customer.CustNum
left join Erp.OrderRel as OrderRel on 
	OrderRel.Company = InvcDtl.Company
	and OrderRel.OrderNum = InvcDtl.OrderNum
	and OrderRel.OrderLine = InvcDtl.OrderLine
	and OrderRel.OrderRelNum = InvcDtl.OrderRelNum
where (InvcHead.InvoiceDate >= convert(date, '20190101', 112))
--AND InvcHead.InvoiceNum = '410130'
--AND InvcHead.OrderNum = '2352243'
--UNION ALL 
--select 
--	[InvcHead].[InvoiceDate] as [InvcHead_InvoiceDate],
--	[InvcHead].[InvoiceNum] as [InvcHead_InvoiceNum],
--	[InvcHead].[PONum] as [InvcHead_PONum],
--	[InvcHead].[DocInvoiceAmt] as [InvcHead_DocInvoiceAmt],
--	[InvcHead].[DocInvoiceBal] as [InvcHead_DocInvoiceBal],
--	[InvcHead].[Posted] as [InvcHead_Posted],
--	[InvcDtl].[PartNum] as [InvcDtl_PartNum],
--	[InvcDtl].[LineDesc] as [InvcDtl_LineDesc],
--	[InvcDtl].[UnitPrice] as [InvcDtl_UnitPrice],
--	[InvcDtl].[SellingShipQty] as [InvcDtl_SellingShipQty],
--	((InvcDtl.UnitPrice* InvcDtl.SellingShipQty)*1.1) as [Calculated_LineTotal],
--	[Customer].[CustID] as [Customer_CustID],
--	[Customer].[Name] as [Customer_Name],
--	[InvcHead].[OrderNum] as [InvcHead_OrderNum],0,0,0,0,0,0
--	--,[OrderRel].[PONum] as [OrderRel_PONum],
--	--[OrderRel].[POLine] as [OrderRel_POLine],
--	--[OrderRel].[PORelNum] as [OrderRel_PORelNum],
--	--OrderRel.OrderNum ,
--	--OrderRel.OrderLine ,
--	--OrderRel.OrderRelNum 
--from Erp.InvcHead as InvcHead
--inner join Erp.InvcDtl as InvcDtl on 
--	InvcHead.Company = InvcDtl.Company
--	and InvcHead.InvoiceNum = InvcDtl.InvoiceNum
--inner join Erp.Customer as Customer on 
--	InvcDtl.Company = Customer.Company
--	and InvcDtl.CustNum = Customer.CustNum
----inner join Erp.OrderRel as OrderRel on 
----	OrderRel.Company = InvcDtl.Company
----	and OrderRel.OrderNum = InvcDtl.OrderNum
----	and OrderRel.OrderLine = InvcDtl.OrderLine
----	and OrderRel.OrderRelNum = InvcDtl.OrderRelNum
--where (InvcHead.InvoiceDate >= convert(date, '20190101', 112))
----AND InvcHead.InvoiceNum = '410130'
----AND InvcHead.OrderNum = 0
----order by InvcHead.InvoiceDate
