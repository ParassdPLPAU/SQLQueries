with [LatestReceipt_AllParts] as 
(select 
	[Vendor].[VendorID] as [Vendor_VendorID],
	[RcvDtl].[ReceiptDate] as [RcvDtl_ReceiptDate],
	[RcvDtl].[PONum] as [RcvDtl_PONum],
	[POHeader].[OrderDate] as [POHeader_OrderDate],
	[RcvDtl].[POLine] as [RcvDtl_POLine],
	[RcvDtl].[PORelNum] as [RcvDtl_PORelNum],
	[RcvDtl].[PartNum] as [RcvDtl_PartNum],
	[RcvDtl].[ReceivedTo] as [RcvDtl_ReceivedTo],
	[RcvDtl].[OurUnitCost] as [RcvDtl_OurUnitCost],
	[RcvDtl].[VendorUnitCost] as [RcvDtl_VendorUnitCost],
	[RcvDtl].[DocUnitCost] as [RcvDtl_DocUnitCost],
	[RcvDtl].[DocVendorUnitCost] as [RcvDtl_DocVendorUnitCost],
	[RcvDtl].[OurQty] as [RcvDtl_OurQty],
	[RcvDtl].[RevisionNum] as [RcvDtl_RevisionNum],
	(ROW_NUMBER() OVER (
             PARTITION BY RcvDtl.PartNum 
             ORDER BY RcvDtl.ReceiptDate DESC, RcvDtl.OurUnitCost DESC
         )) as [Calculated_RowNum],
	[RcvDtl].[Company] as [RcvDtl_Company]
from Erp.RcvDtl as RcvDtl
inner join Erp.Vendor as Vendor on 
	RcvDtl.Company = Vendor.Company
	and RcvDtl.VendorNum = Vendor.VendorNum
inner join Erp.POHeader as POHeader on 
	RcvDtl.Company = POHeader.Company
	and RcvDtl.PONum = POHeader.PONum)
 ,[LatestPrice_AllParts] as 
(select 
	[Vendor1].[VendorID] as [Vendor1_VendorID],
	[VendPart].[PartNum] as [VendPart_PartNum],
	[VendPart].[EffectiveDate] as [VendPart_EffectiveDate],
	[VendPart].[BaseUnitPrice] as [VendPart_BaseUnitPrice],
	[VendPart].[CurrencyCode] as [VendPart_CurrencyCode],
	(ROW_NUMBER() OVER (
             PARTITION BY VendPart.PartNum 
             ORDER BY VendPart.EffectiveDate DESC, VendPart.BaseUnitPrice DESC
         )) as [Calculated_RowNum],
	[VendPart].[Company] as [VendPart_Company]
from Erp.VendPart as VendPart
inner join Erp.Vendor as Vendor1 on 
	VendPart.Company = Vendor1.Company
	and VendPart.VendorNum = Vendor1.VendorNum
inner join Erp.PartPlant as PartPlant on 
	VendPart.PartNum = PartPlant.PartNum
	and VendPart.VendorNum = PartPlant.VendorNum
	and VendPart.Company = PartPlant.Company)

select 
	[Part].[PartNum] as [Part_PartNum],
	[Part].[PartDescription] as [Part_PartDescription],
	--[PartRev].[RevisionNum] as [PartRev_RevisionNum],
	--[PartRev].[RevShortDesc] as [PartRev_RevShortDesc],
	--[PartRev].[Approved] as [PartRev_Approved],
	[Part].[InActive] as [Part_InActive],
	[PartWhse].[WarehouseCode] as [PartWhse_WarehouseCode],
	[Part].[TypeCode] as [Part_TypeCode],
	PartWhse.SystemAbc,
	((PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost+ PartCost.StdMtlBurCost)) as [Calculated_TotalStdCost],
	[PartWhse].[OnHandQty] as [PartWhse_OnHandQty],
	[PartCost].[StdLaborCost] as [PartCost_StdLaborCost],
	[PartCost].[StdBurdenCost] as [PartCost_StdBurdenCost],
	[PartCost].[StdMaterialCost] as [PartCost_StdMaterialCost],
	[PartCost].[StdSubContCost] as [PartCost_StdSubContCost],
	[PartCost].[StdMtlBurCost] as [PartCost_StdMtlBurCost],
	((PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost+ PartCost.StdMtlBurCost) * PartWhse.OnHandQty) as [Calculated_TotalCost],
	[PartCost].[LastLaborCost] as [PartCost_LastLaborCost],
	[PartCost].[LastBurdenCost] as [PartCost_LastBurdenCost],
	[PartCost].[LastMaterialCost] as [PartCost_LastMaterialCost],
	[PartCost].[LastSubContCost] as [PartCost_LastSubContCost],
	[PartCost].[LastMtlBurCost] as [PartCost_LastMtlBurCost],
	(PartCost.LastLaborCost+ PartCost.LastBurdenCost+ PartCost.LastSubContCost+ PartCost.LastMtlBurCost+ PartCost.LastMaterialCost) as [Calculated_TotalLastCost],
	[LatestPrice_AllParts].[Vendor1_VendorID] as [Vendor1_VendorID],
	[LatestPrice_AllParts].[VendPart_EffectiveDate] as [VendPart_EffectiveDate],
	[LatestPrice_AllParts].[VendPart_BaseUnitPrice] as [VendPart_BaseUnitPrice],
	[LatestPrice_AllParts].[VendPart_CurrencyCode] as [VendPart_CurrencyCode],
	[LatestReceipt_AllParts].[RcvDtl_PONum] as [RcvDtl_PONum],
	[LatestReceipt_AllParts].[RcvDtl_POLine] as [RcvDtl_POLine],
	[LatestReceipt_AllParts].[RcvDtl_PORelNum] as [RcvDtl_PORelNum],
	[LatestReceipt_AllParts].[POHeader_OrderDate] as [POHeader_OrderDate],
	[LatestReceipt_AllParts].[RcvDtl_ReceiptDate] as [RcvDtl_ReceiptDate],
	[LatestReceipt_AllParts].[Vendor_VendorID] as [Vendor_VendorID],
	[LatestReceipt_AllParts].[RcvDtl_OurQty] as [RcvDtl_OurQty],
	[LatestReceipt_AllParts].[RcvDtl_OurUnitCost] as [RcvDtl_OurUnitCost],
	[LatestReceipt_AllParts].[RcvDtl_VendorUnitCost] as [RcvDtl_VendorUnitCost],
	[LatestReceipt_AllParts].[RcvDtl_DocVendorUnitCost] as [RcvDtl_DocVendorUnitCost],
	[LatestReceipt_AllParts].[RcvDtl_DocUnitCost] as [RcvDtl_DocUnitCost],
	CASE WHEN [LatestPrice_AllParts].VendPart_BaseUnitPrice = 0 THEN 0
	ELSE ROUND(((LatestPrice_AllParts.VendPart_BaseUnitPrice - LatestReceipt_AllParts.RcvDtl_DocUnitCost)/LatestPrice_AllParts.VendPart_BaseUnitPrice * 100),2) END AS 'PriceListVariation%',
	ROUND(LatestReceipt_AllParts.RcvDtl_OurUnitCost/LatestReceipt_AllParts.RcvDtl_DocUnitCost,2) AS 'ExchangeRateValue',	
	[LatestReceipt_AllParts].[RcvDtl_ReceivedTo] as [RcvDtl_ReceivedTo]
	
from Erp.Part as Part
inner join Erp.PartWhse as PartWhse on 
	Part.Company = PartWhse.Company
	and Part.PartNum = PartWhse.PartNum
inner join Erp.PartCost as PartCost on 
	Part.Company = PartCost.Company
	and Part.PartNum = PartCost.PartNum
--left outer join Erp.PartRev as PartRev on 
--	Part.Company = PartRev.Company
--	and Part.PartNum = PartRev.PartNum
left outer join  LatestReceipt_AllParts  as LatestReceipt_AllParts on 
	Part.PartNum = LatestReceipt_AllParts.RcvDtl_PartNum
	and Part.Company = LatestReceipt_AllParts.RcvDtl_Company
	and ( LatestReceipt_AllParts.Calculated_RowNum = 1  )

left outer join  LatestPrice_AllParts  as LatestPrice_AllParts on 
	Part.PartNum = LatestPrice_AllParts.VendPart_PartNum
	and Part.Company = LatestPrice_AllParts.VendPart_Company
	and ( LatestPrice_AllParts.Calculated_RowNum = 1  )

where (PartWhse.WarehouseCode = '190') --and Part.PartNum in ('A-A7317','IQSOF4540-150-V2','IQSOF4520-150-V2','AFG-188-CL','AFS-083','I-C8-1050-7595C-2300H-127/254-GR','IPF7624','A-INS154947','RTX8845G','WR6118H','A-INS154930','ANCHOR-200-1-IN','VSD-4032-B','I-C16-1950-14400C-4400H-254/356-GR','9075','I-C6-1950-14400C-4400H-254/275-GR','A-A4185-53','D-K122-WP','I-C12.5-1050-6125C-2300H-127/275-GR','HBB-16080-8.8','RTX8045V','AWFG-090-X','SPQQ-293-500-2','ERBP3','D-DB05B15SS','PSCCT-90-118','EPTCU-70-11.5AF-M12-EE','A-X0347-06','I-C16-1300-9075C-2900H-127/325-GR','D-HL162107','I-CS-160-330-EB-11350C-3200H-GR','RTX8245V','RMCE-32-8-3-U','YPWC-500-2','GRP-500-2','A-A2748-03','GRBS-500-2','YPR-160-520-4P','CFG-083','SPT-380-R','CFG-100-CL','D-CCC80120','A-A8175','A-A5719-04','D-K220','RMTA-BB-100108000','GRT-330-SS1-21-9-601-1','I-C10-325-1815C-770H 127/127','APG-315-315-2','RMTA-BB-2001210000','RMSP-2400-1200-10','SC-160-2','RMTA-206-126-V','A-ELC156425','GCB-16135-8.8','12-0070-2-RB','12-0070-1-RB','RMCU-70MM2','D-K446','D-UEC11MGE','BCST-4035-3PA-NP','A-ELC152364','IQRT-PRAIL-333','A-A0158-08','PSG-040-3S-FH','AWFG-075-X','D-ABC5-1','D-UET8O','SVD-0106','E-3004155','S-210-1','RMTA-BB-800411000','A-A4385-08','CFS-235','RMRA-65.0-Y','A-ELC156940','A-ELC152339','A-A2748-05','A-X0066','A-X0107-02','A-A3-082-0924-N9','SPT-520','CFG-060','CGS-2101','AGNI-55021','A-A4185-52','AGNI-55018','A-X0273','SHBA-16070E-S/S','RTC8045','WJA-120-A','A-A4185-59','ACSR-54/7/3.50','SSDTS-01','E-3012966','RMTA-BB-114063930','IPVHOOD320H','CBE-127-1400','RTX8842G','RMCST-19-3.2','SVD-0102','PSG-054-3S-FH','CBE-127-3000','CBE-127-COUPLER','A-ELC152366','AFG-238-CL','AFG-163-CL','OPGWAC-01','ACSR-30/7/2.50','RTC8245','D-FORL170LL-4-SUB','GRS-330-1','RMRSS-32.0-GR304','AGS-5139-20','A-A4390-07','A-A1529-49','A-A7316-01','YPR-160-460-6','L-160-100-2','AGS-5139-16','A-A1529-33','CTA-293-3631AC','OPGWFWTS-1016R-A-WP','IQOF9512-150','IQS8942V-WSA','CTA-163-11111T')