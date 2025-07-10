WITH BASE AS ( 
    SELECT 
        V.VendorID,
		RD.PackSlip,
        RD.ReceiptDate,
        RD.PONum,
		PH.OrderDate,
		RD.POLine,
		RD.PORelNum,
        RD.PartNum,
		RD.ReceivedTo,
        RD.OurUnitCost,
		RD.DocUnitCost,
        RD.OurQty,
        RD.RevisionNum,
		PH.CurrencyCode
        --ROW_NUMBER() OVER (
        --    PARTITION BY RD.PartNum 
        --    ORDER BY RD.ReceiptDate DESC, RD.OurUnitCost DESC
        --) AS RowNum
    FROM
        erp.RcvDtl RD 
    INNER JOIN 
        erp.vendor V 
        ON V.vendornum = RD.vendornum
	INNER JOIN
		erp.POHeader PH
		ON PH.PONum = RD.PONum
	INNER JOIN
		erp.PODetail PD
		ON PD.PONum = RD.PONum
		AND PD.POLine = RD.POLine
	INNER JOIN
		erp.PORel PR
		ON PR.PONum = RD.PONum
		AND PR.POLine = RD.POLine
		AND PR.PORelNum = RD.PORelNum
	WHERE (ReceivedTo = 'PUR-STK')
	UNION ALL
	SELECT 
        V.VendorID,
		DSD.PackSlip,
        DSD.ReceiptDate,
        DSD.PONum,
		PH.OrderDate,
		DSD.POLine,
		DSD.PORelNum,
        DSD.PartNum, 
		'PUR-DRP',
        DSD.OurUnitCost,
		DSD.DocUnitCost,
        DSD.OurQty,
        DSD.RevisionNum,
		PH.CurrencyCode
        --ROW_NUMBER() OVER (
        --    PARTITION BY DSD.PartNum 
        --    ORDER BY DSD.ReceiptDate DESC, DSD.OurUnitCost DESC
        --) AS RowNum
    FROM
        erp.DropShipDtl DSD 
    INNER JOIN 
        erp.vendor V 
        ON V.vendornum = DSD.vendornum
	INNER JOIN
		erp.POHeader PH
		ON PH.PONum = DSD.PONum
), LatestReceipt_AllParts AS (
	SELECT *, ROW_NUMBER() OVER (
            PARTITION BY PartNum 
            ORDER BY ReceiptDate DESC, OurUnitCost DESC
        ) AS RowNum FROM BASE
), LatestPrice_AllParts AS (
	SELECT 
        V.VendorID,VP.PartNum,VP.EffectiveDate,VP.BaseUnitPrice,VP.CurrencyCode,
		ROW_NUMBER() OVER (
            PARTITION BY VP.PartNum 
            ORDER BY VP.EffectiveDate DESC, VP.BaseUnitPrice DESC
        ) AS RowNum
    FROM 
        erp.VendPart VP
    INNER JOIN 
        erp.vendor V 
        ON V.vendornum = VP.vendornum
	INNER JOIN	erp.PartPlant PP 
		ON PP.PartNum = VP.PartNum
	WHERE PP.VendorNum = VP.VendorNum 
) 
Select 
	PartPlant.Plant,
	[PartCost].[PartNum] as [PartCost_PartNum],
	[PartPlant].[SourceType] as [PartPlant_SourceType],
	[PartRev].[RevisionNum] as [PartRev_RevisionNum],
	[PartRev].[Approved] as [PartRev_Approved],
	Vendor.[VendorID] as 'Preferred Vendor',
	PartWhse.OnHandQty,
	PartWhse.OnHandQty * (PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost + PartCost.StdMtlBurCost) AS 'TotalStdCostSOH',
	LatestPrice_AllParts.BaseUnitPrice,
	LatestPrice_AllParts.EffectiveDate,
	LatestPrice_AllParts.CurrencyCode AS 'PriceListCurrencyCode',
	[PartCost].[StdLaborCost] as [PartCost_StdLaborCost],
	[PartCost].[StdBurdenCost] as [PartCost_StdBurdenCost],
	[PartCost].[StdMaterialCost] as [PartCost_StdMaterialCost],
	[PartCost].[StdSubContCost] as [PartCost_StdSubContCost],
	[PartCost].[StdMtlBurCost] as [PartCost_StdMtlBurCost],
	(PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost + PartCost.StdMtlBurCost) as [Calculated_TotalStdCost],
	[PartCost].[LastLaborCost] as [PartCost_LastLaborCost],
	[PartCost].[LastBurdenCost] as [PartCost_LastBurdenCost],
	[PartCost].[LastMaterialCost] as [PartCost_LastMaterialCost],
	[PartCost].[LastSubContCost] as [PartCost_LastSubContCost],
	[PartCost].[LastMtlBurCost] as [PartCost_LastMtlBurCost],
	(PartCost.LastLaborCost + PartCost.LastBurdenCost + PartCost.LastMaterialCost + PartCost.LastSubContCost + PartCost.LastMtlBurCost) as [Calculated_TotalLastCost],
	LatestReceipt_AllParts.ReceiptDate,
	LatestReceipt_AllParts.VendorID,
	LatestReceipt_AllParts.CurrencyCode AS 'ReceiptCurrencyCode',
	LatestReceipt_AllParts.OurUnitCost,
	LatestReceipt_AllParts.DocUnitCost,
	CASE 
		WHEN LatestPrice_AllParts.BaseUnitPrice = 0 
			THEN 0
		ELSE 
			CASE
				WHEN LatestPrice_AllParts.CurrencyCode = LatestReceipt_AllParts.CurrencyCode THEN
					CAST((LatestPrice_AllParts.BaseUnitPrice - LatestReceipt_AllParts.DocUnitCost)/LatestPrice_AllParts.BaseUnitPrice * 100 AS DECIMAL (14,2)) 
				ELSE 
					0
				END
	END AS 'PriceListVariation%',
	CAST((LatestReceipt_AllParts.OurUnitCost /LatestReceipt_AllParts.DocUnitCost) AS DECIMAL (14,2)) AS 'ReceiptExchangeRateValue',
	LatestReceipt_AllParts.OurQty,
	LatestReceipt_AllParts.PONum,
	LatestReceipt_AllParts.POLine,
	LatestReceipt_AllParts.PORelNum,
	LatestReceipt_AllParts.ReceivedTo,
	LatestReceipt_AllParts.OrderDate,
	LatestReceipt_AllParts.RevisionNum 
from erp.Part as Part
left join Erp.PartRev as PartRev on 
	Part.Company = PartRev.Company
	and Part.PartNum = PartRev.PartNum
	and Partrev.Approved <> 0
inner join Erp.PartCost as PartCost on 
	Part.PartNum = PartCost.PartNum
	and Part.Company = PartCost.Company
inner join Erp.PartPlant as PartPlant on 
	PartPlant.Company = Part.Company
	and PartPlant.PartNum = Part.PartNum
inner join erp.Vendor on
	Vendor.VendorNum = PartPlant.VendorNum
inner join LatestReceipt_AllParts on
	Part.PartNum = LatestReceipt_AllParts.PartNum
	and LatestReceipt_AllParts.RowNum = 1
left join LatestPrice_AllParts on 
	Part.PartNum = LatestPrice_AllParts.PartNum
	and  1 = LatestPrice_AllParts.RowNum 
inner join erp.PartWhse on
	PartWhse.PartNum = Part.PartNum
	and PartWhse.WarehouseCode = '190'
where (Part.InActive = 0)
AND PartPlant.Plant = 'GLENDN' 
order by PartCost_PartNum

