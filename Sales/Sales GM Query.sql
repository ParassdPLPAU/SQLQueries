/*
Sales Gross Margin Query
*/

WITH BASE AS (
	SELECT invcdtl.Company,invcdtl.OrderNum, invcdtl.OrderLine,InvcDtl.InvoiceNum,InvcDtl.InvoiceLine,InvcDtl.ProdCode,InvcDtl.RMANum,InvcDtl.RMALine,
	InvcDtl.ShipToCustNum,InvcDtl.ShipToNum,InvcDtl.PackNum,InvcDtl.ExtPrice,InvcDtl.Discount,InvcDtl.PartNum,InvcDtl.LineDesc,InvcDtl.SalesUM,InvcDtl.SellingShipQty,InvcDtl.DropShipPackSlip,
	InvcDtl.DropShipPackLine,InvcDtl.PackLine,
	(case  
			 when OrderDtl.KitFlag <> 'C' then 
				  case
					  when InvcDtl.OurShipQty <> 0 and InvcDtl.RMANum = 0 then round(InvcDtl.OurShipQty * InvcDtl.LbrUnitCost,2)
					  else round(InvcDtl.SellingShipQty * InvcDtl.LbrUnitCost ,2)
				  end
			 else 0
		end) as [Calculated_LabourCost],
       (case  
			 when OrderDtl.KitFlag <> 'C' then 
				  case
					  when InvcDtl.OurShipQty <> 0 and InvcDtl.RMANum = 0 then round(InvcDtl.OurShipQty * InvcDtl.BurUnitCost,2)
					  else round(InvcDtl.SellingShipQty * InvcDtl.BurUnitCost ,2)
				  end
			 else 0
		end) as [Calculated_BurdenCost],
       (case  
			 when OrderDtl.KitFlag <> 'C' then 
				  case
					  when InvcDtl.OurShipQty <> 0 and InvcDtl.RMANum = 0 then round(InvcDtl.OurShipQty * InvcDtl.MtlUnitCost,2)
					  else round(InvcDtl.SellingShipQty * InvcDtl.MtlUnitCost ,2)
				  end
			 else 0
		end) as [Calculated_MtlCost],
       (case  
			 when OrderDtl.KitFlag <> 'C' then 
				  case
					  when InvcDtl.OurShipQty <> 0 and InvcDtl.RMANum = 0 then round(InvcDtl.OurShipQty * InvcDtl.SubUnitCost,2)
					  else round(InvcDtl.SellingShipQty * InvcDtl.SubUnitCost ,2)
				  end
			 else 0
		end) as [Calculated_SubcontractCost],
       (case  
			 when OrderDtl.KitFlag <> 'C' then 
				  case
					  when InvcDtl.OurShipQty <> 0 and InvcDtl.RMANum = 0 then round(InvcDtl.OurShipQty * InvcDtl.MtlBurUnitCost,2)
					  else round(InvcDtl.SellingShipQty * InvcDtl.MtlBurUnitCost ,2)
				  end
			 else 0
		end) as [Calculated_MtlBurdenCost],
		(InvcDtl.ExtPrice - InvcDtl.Discount) as [Calculated_TotalPrice]
		FROM erp.InvcDtl LEFT JOIN erp.OrderDtl
		ON InvcDtl.OrderNum = OrderDtl.OrderNum AND
		InvcDtl.OrderLine = OrderDtl.OrderLine AND
		InvcDtl.Company = OrderDtl.Company 
	
), BASE_2 AS(--added to calculate the total GM
	SELECT *,([Calculated_LabourCost]+[Calculated_BurdenCost]+[Calculated_MtlBurdenCost]+[Calculated_SubcontractCost]+[Calculated_MtlCost]) AS Calculated_TotalStdCost FROM BASE
) 
select 
       [InvcHead].[InvoiceNum] as [InvcHead_InvoiceNum],
       [InvcHead].[InvoiceDate] as [InvcHead_InvoiceDate],
       [InvcHead].[PONum] as [InvcHead_PONum],
       [Customer].[CustID] as [Customer_CustID],
       [Customer].[Name] as [Customer_Name],
       [Customer].[GroupCode] as [Customer_GroupCode],
       [CustGrup].[GroupDesc] as [CustGrup_GroupDesc],
       [BASE_2].[PartNum] as [InvcDtl_PartNum],
       [BASE_2].[LineDesc] as [InvcDtl_LineDesc],
       [BASE_2].[ProdCode] as [InvcDtl_ProdCode],
       [ProdGrup].[Description] as [ProdGrup_Description],
       [Part].[CSG_c] as [Part_CSG_c],
       [BASE_2].[SellingShipQty] as [InvcDtl_SellingShipQty],
       [BASE_2].[SalesUM] as [InvcDtl_SalesUM],
       Calculated_TotalStdCost,
	   [Customer].[Rebate_Percentage_c] as [Customer_Rebate_Percentage_c],
       (([Calculated_TotalPrice] * Customer.Rebate_Percentage_c)/100) as [Calculated_Rebate_Amount],
       (BASE_2.ExtPrice - BASE_2.Discount - Calculated_TotalStdCost - ([Customer].[Rebate_Percentage_c]*[Calculated_TotalPrice]*0.01)) as [Calculated_Profit],
	   [Calculated_TotalPrice],
       ((case 
			when [Calculated_TotalPrice] <> 0 then round(((BASE_2.ExtPrice - BASE_2.Discount - Calculated_TotalStdCost - 0.01*[Customer].[Rebate_Percentage_c]*[Calculated_TotalPrice]) / [Calculated_TotalPrice]) * 100,2)  
			else 0  
		end)) as [Calculated_ProfitPer],
       [InvcHead].[InvoiceType] as [InvcHead_InvoiceType],
       [BASE_2].[RMANum] as [InvcDtl_RMANum],
       [BASE_2].[RMALine] as [InvcDtl_RMALine],
       [BASE_2].[OrderNum] as [InvcDtl_OrderNum],
       [GLAcctDisp].[GLAcctDisp] as [GLAcctDisp_GLAcctDisp],
       [ShipTo].[ShipToNum] as [ShipTo_ShipToNum],
       [ShipTo].[State] as [ShipTo_State],
       [ShipHead].[TrackingNumber] as [ShipHead_TrackingNumber],
       [OrderDtl].[Phocus_ProdCode_c] as [OrderDtl_Phocus_ProdCode_c],
       [AnalysisCd].[Description] as [AnalysisCd_Description],
       [TranGLC].[UserCanModify] as [TranGLC_UserCanModify],
       [BASE_2].[PackNum] as [InvcDtl_PackNum],
       [BASE_2].[PackLine] as [InvcDtl_PackLine],
       [OrderDtl].[OrderLine] as [OrderDtl_OrderLine],
       [BASE_2].[DropShipPackSlip] as [InvcDtl_DropShipPackSlip],
       [BASE_2].[DropShipPackLine] as [InvcDtl_DropShipPackLine],
       [Customer].[SalesRepCode] as [Customer_SalesRepCode],
       [OrderHed].[ProjectID_c] as [OrderHed_ProjectID_c],
       [OrderHed].[OrderDate] as [OrderHed_OrderDate],
       [OrderHed].[OrderType_c] as [OrderHed_OrderType_c]
from Erp.InvcHead as InvcHead
inner join BASE_2 as BASE_2 on 
       InvcHead.Company = BASE_2.Company
       and InvcHead.InvoiceNum = BASE_2.InvoiceNum
left outer join Erp.ProdGrup as ProdGrup on 
       BASE_2.Company = ProdGrup.Company
       and BASE_2.ProdCode = ProdGrup.ProdCode
left outer join dbo.OrderDtl as OrderDtl on 
       BASE_2.Company = OrderDtl.Company
       and BASE_2.OrderNum = OrderDtl.OrderNum
       and BASE_2.OrderLine = OrderDtl.OrderLine
left outer join Erp.AnalysisCd as AnalysisCd on 
       OrderDtl.Company = AnalysisCd.Company
       and OrderDtl.Phocus_ProdCode_c = AnalysisCd.AnalysisCode
       and ( AnalysisCd.material = 0  )
inner join dbo.OrderHed as OrderHed on 
       OrderDtl.Company = OrderHed.Company
       and OrderDtl.OrderNum = OrderHed.OrderNum
left outer join Erp.RMARcpt as RMARcpt on 
       BASE_2.Company = RMARcpt.Company
       and BASE_2.RMANum = RMARcpt.RMANum
       and BASE_2.RMALine = RMARcpt.RMALine
left outer join Erp.TranGLC as TranGLC on 
       BASE_2.Company = TranGLC.Company
       and BASE_2.InvoiceNum = TranGLC.Key1
       and BASE_2.InvoiceLine = TranGLC.Key2
       and ( TranGLC.RelatedToFile = 'InvcDtl'  and (TranGLC.GLAcctContext like 'Sales%'  or TranGLC.GLAcctContext like 'Returns%' ) and TranGLC.UserCanModify = 0  )
left outer join Erp.GLAcctDisp as GLAcctDisp on 
       TranGLC.Company = GLAcctDisp.Company
       and TranGLC.COACode = GLAcctDisp.COACode
       and TranGLC.GLAccount = GLAcctDisp.GLAccount
left outer join Erp.ShipTo as ShipTo on 
       BASE_2.Company = ShipTo.Company
       and BASE_2.ShipToCustNum = ShipTo.CustNum
       and BASE_2.ShipToNum = ShipTo.ShipToNum
left outer join Erp.ShipHead as ShipHead on 
       BASE_2.Company = ShipHead.Company
       and BASE_2.PackNum = ShipHead.PackNum
inner join dbo.Part as Part on 
       Part.Company = BASE_2.Company
       and Part.PartNum = BASE_2.PartNum
inner join dbo.Customer as Customer on 
       Customer.Company = InvcHead.Company
       and Customer.CustNum = InvcHead.CustNum
left outer join Erp.CustGrup as CustGrup on 
       Customer.Company = CustGrup.Company
       and Customer.GroupCode = CustGrup.GroupCode
where InvcHead.Company = 'AU6101'  and InvcHead.Posted = 1  and InvcHead.UnappliedCash = 0  and InvcHead.StartUp = 0  and (InvcHead.InvoiceType = 'SHP'  or InvcHead.InvoiceType = 'MIS' ) and InvcHead.DebitNote = 0  and InvcHead.InvoiceDate >= convert(date, '20250501', 112) and InvcHead.InvoiceDate < convert(date, '20250601', 112)

