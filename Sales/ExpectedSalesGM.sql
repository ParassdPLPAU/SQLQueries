WITH COST AS (
	SELECT 
		PartCost.PartNum,
		(PartCost.StdMaterialCost+
		PartCost.StdLaborCost+
		PartCost.StdBurdenCost+
		PartCost.StdMtlBurCost+
		PartCost.StdSubContCost) AS 'TotalStdCost'
	FROM 
		erp.PartCost
)
SELECT 
	C.CustID,
	OD.PartNum,
	RL.OrderNum,
	RL.OrderLine,
	RL.OrderRelNum,
	RL.ReqDate AS 'ShipBy',
	OD.UnitPrice,
	OD.OrderQty,
	COST.TotalStdCost,
	(OD.UnitPrice * OD.OrderQty) AS 'LineValue',
	(COST.TotalStdCost*OD.OrderQty) AS 'LineCost',
	(OD.UnitPrice - COST.TotalStdCost-(0.01*C.Rebate_Percentage_c*OD.UnitPrice))*OD.OrderQty AS 'TotalMargin',
	CASE WHEN OD.UnitPrice <> 0 THEN
		100*(OD.UnitPrice - COST.TotalStdCost-(0.01*C.Rebate_Percentage_c*OD.UnitPrice)) / OD.UnitPrice
	ELSE
		OD.UnitPrice
	END AS 'Margin%',
	OD.OrderQty,
	C.Rebate_Percentage_c
	--OD.VoidLine,
	--OD.OpenLine,
	--RL.OpenRelease,
	--RL.VoidRelease
FROM 
	OrderDtl OD
LEFT JOIN 
	OrderRel RL ON
	OD.OrderNum = RL.OrderNum AND
	OD.OrderLine = RL.OrderLine AND
	OD.Company = RL.Company
INNER JOIN 
	COST ON
	COST.PartNum = OD.PartNum
INNER JOIN
	dbo.Customer C ON
	C.CustNum = OD.CustNum
WHERE CAST(ReqDate AS DATE) >= CAST(GETDATE() AS DATE)
--AND OD.KitFlag <> 'C'
AND OD.VoidLine = 0
AND OD.OpenLine = 1
ORDER BY shipby ASC

--SELECT --OD.PartNum,RL.ReqDate, (UnitPrice * OrderQty) 
--SUM(UnitPrice * OrderQty) 
--FROM 
--	OrderDtl OD
--LEFT JOIN 
--	OrderRel RL ON
--	OD.OrderNum = RL.OrderNum AND
--	OD.OrderLine = RL.OrderLine AND
--	OD.Company = RL.Company
--WHERE CAST(ReqDate AS DATE) >= CAST(GETDATE() AS DATE) 
--AND CAST(ReqDate AS DATE) <= CAST('2024-11-30' AS DATE)
--AND OD.KitFlag <> 'C'
--AND OD.VoidLine = 0
--AND OD.OpenLine = 1

--select TOP(100) *  from erp.InvcDtl order by shipdate desc

SELECT Part.PartNum,COUNT(*) AS 'Count' 
FROM erp.partrev
INNER JOIN erp.Part ON
Part.Partnum = partrev.PartNum
WHERE APPROVED = 1
and part.InActive = 0
GROUP BY part.PartNum
order by Count desc

/*
 * Disclaimer!!!
 * This is not a real query being executed, but a simplified version for general vision.
 * Executing it with any other tool may produce a different result.
 */
 
select
	[Part].[PartNum] as [Part_PartNum],
	[Part].[PartDescription] as [Part_PartDescription],
	[PartWhse].[WarehouseCode] as [PartWhse_WarehouseCode],
	[PartWhse].[OnHandQty] as [PartWhse_OnHandQty],
	[PartCost].[StdLaborCost] as [PartCost_StdLaborCost],
	[PartCost].[StdBurdenCost] as [PartCost_StdBurdenCost],
	[PartCost].[StdMaterialCost] as [PartCost_StdMaterialCost],
	[PartCost].[StdSubContCost] as [PartCost_StdSubContCost],
	[PartCost].[StdMtlBurCost] as [PartCost_StdMtlBurCost],
	((PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost+ PartCost.StdMtlBurCost) * PartWhse.OnHandQty) as [Calculated_TotalCost],
	[Part].[TypeCode] as [Part_TypeCode],
	[PartRev].[RevisionNum] as [PartRev_RevisionNum],
	((PartCost.StdLaborCost+ PartCost.StdBurdenCost+ PartCost.StdMaterialCost+ PartCost.StdSubContCost+ PartCost.StdMtlBurCost)) as [Calculated_TotalStdCost]
from Erp.Part as Part
inner join Erp.PartWhse as PartWhse on 
	Part.Company = PartWhse.Company
	and Part.PartNum = PartWhse.PartNum
inner join Erp.PartCost as PartCost on 
	Part.Company = PartCost.Company
	and Part.PartNum = PartCost.PartNum
left outer join Erp.PartRev as PartRev on 
	Part.Company = PartRev.Company
	and Part.PartNum = PartRev.PartNum
where (Part.InActive = 0)
 and (PartRev.Approved = 1)