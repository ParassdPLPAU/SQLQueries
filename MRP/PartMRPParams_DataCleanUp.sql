--All active part parameters
Select 
	[PartPlant].[Plant] as [PartPlant_Plant],
	[PartPlant].[PartNum] as [PartPlant_PartNum],
	PrimWhse,
	SafetyQty,
	[PartPlant].[SourceType] as [PartPlant_SourceType],
	[PartPlant].[PersonID] as [PartPlant_PersonID],
	[PartPlant].[BuyerID] as [PartPlant_BuyerID],
	Vendor.VendorID,
	[Part].[ProdCode] as [Part_ProdCode],
	[Part].[ClassID] as [Part_ClassID],
	[PartPlant].[PlanTimeFence] as [PartPlant_PlanTimeFence],
	(CASE WHEN
       PartPlant.SourceType = 'P'
       THEN PartPlant.LeadTime
       ELSE
       PartPlant.TotMfgLeadTimeSys
	END) as [Calculated_LeadTime],
	[PartPlant].[DaysOfSupply] as [PartPlant_DaysOfSupply],
	[PartPlant].[MfgLotSize] as [PartPlant_MfgLotSize],
	[PartPlant].[MfgLotMultiple] as [PartPlant_MfgLotMultiple],
	(CASE WHEN PartPlant.SourceType = 'P' THEN PartPlant.MinOrderQty
   ELSE PartPlant.MinMfgLotSize 
   END) as [Calculated_MOQ],
	[PartPlant].[MaxMfgLotSize] as [PartPlant_MaxMfgLotSize],
	[PartPlant].[ReschedOutDelta] as [PartPlant_ReschedOutDelta],
	[PartPlant].[ReschedInDelta] as [PartPlant_ReschedInDelta],
	[PartPlant].[KitTime] as [PartPlant_KitTime],
	[PartPlant].[ReceiveTime] as [PartPlant_ReceiveTime],
	[Part].[Constrained] as [Part_Constrained],
	[PartPlant].[SafetyQty] as [PartPlant_SafetyQty],
	[PartPlant].[DemandQty] as [PartWhse_DemandQty],
	[PartPlant].[GenerateSugg] as [PartPlant_GenerateSugg],
	[PartPlant].[MultiLevelCTP] as [PartPlant_MultiLevelCTP],
	[PartPlant].[ProcessMRP] as [PartPlant_ProcessMRP]
from Erp.Part as Part
inner join Erp.PartPlant as PartPlant on 
	Part.Company = PartPlant.Company
	and Part.PartNum = PartPlant.PartNum
inner join erp.vendor on
	Vendor.VendorNum = PartPlant.VendorNum
where (Part.InActive = 0)
order by PartPlant_PartNum


--Parts with demand within the last 12 months
WITH JobCount AS (
	SELECT 
		PartNum,
		COUNT(JobNum) AS 'TotalJobs'
	FROM 
		erp.JobMtl
	WHERE ReqDate <= GETDATE()
	AND ReqDate >= GETDATE()-365
	GROUP BY PartNum
),OrderCount AS (
	SELECT 
		PartNum,
		COUNT(*) AS 'TotalOrders'
	FROM
		erp.OrderDtl 
	WHERE NeedByDate <= GETDATE()
	AND NeedByDate >= GETDATE()-365
	GROUP BY PartNum
	--ORDER BY TotalOrders DESCselect * from erp.orderdtl
),BASE_1 AS (
	SELECT 
    DISTINCT COALESCE(JobCount.PartNum, OrderCount.PartNum) AS PartNum,
    COALESCE(JobCount.TotalJobs, 0) AS TotalJobDemandCount,
    COALESCE(OrderCount.TotalOrders, 0) AS TotalOrderDemandCount,
    COALESCE(JobCount.TotalJobs, 0) + COALESCE(OrderCount.TotalOrders, 0) AS 'TotalCount'
FROM JobCount
FULL OUTER JOIN OrderCount ON JobCount.PartNum = OrderCount.PartNum
)
--SELECT * FROM BASE_1 INNER JOIN Part ON Part.PartNum = BASE_1.PartNum WHERE Part.InActive = 0 order by totalcount desc
Select 
	[PartPlant].[Plant] as [PartPlant_Plant],
	[PartPlant].[PartNum] as [PartPlant_PartNum],
	PrimWhse,
	TotalJobDemandCount,
	TotalOrderDemandCount,
	TotalCount,
	SafetyQty,
	[PartPlant].[SourceType] as [PartPlant_SourceType],
	[PartPlant].[PersonID] as [PartPlant_PersonID],
	[PartPlant].[BuyerID] as [PartPlant_BuyerID],
	Vendor.VendorID,
	[Part].[ProdCode] as [Part_ProdCode],
	[Part].[ClassID] as [Part_ClassID],
	[PartPlant].[PlanTimeFence] as [PartPlant_PlanTimeFence],
	(CASE WHEN
       PartPlant.SourceType = 'P'
       THEN PartPlant.LeadTime
       ELSE
       PartPlant.TotMfgLeadTimeSys
	END) as [Calculated_LeadTime],
	[PartPlant].[DaysOfSupply] as [PartPlant_DaysOfSupply],
	[PartPlant].[MfgLotSize] as [PartPlant_MfgLotSize],
	[PartPlant].[MfgLotMultiple] as [PartPlant_MfgLotMultiple],
	(CASE WHEN PartPlant.SourceType = 'P' THEN PartPlant.MinOrderQty
   ELSE PartPlant.MinMfgLotSize 
   END) as [Calculated_MOQ],
	[PartPlant].[MaxMfgLotSize] as [PartPlant_MaxMfgLotSize],
	[PartPlant].[ReschedOutDelta] as [PartPlant_ReschedOutDelta],
	[PartPlant].[ReschedInDelta] as [PartPlant_ReschedInDelta],
	[PartPlant].[KitTime] as [PartPlant_KitTime],
	[PartPlant].[ReceiveTime] as [PartPlant_ReceiveTime],
	[Part].[Constrained] as [Part_Constrained],
	[PartPlant].[SafetyQty] as [PartPlant_SafetyQty],
	[PartPlant].[DemandQty] as [PartWhse_DemandQty],
	[PartPlant].[GenerateSugg] as [PartPlant_GenerateSugg],
	[PartPlant].[MultiLevelCTP] as [PartPlant_MultiLevelCTP],
	[PartPlant].[ProcessMRP] as [PartPlant_ProcessMRP]
from BASE_1 
left join	Erp.Part as Part on
	Part.PartNum = BASE_1.PartNum
inner join Erp.PartPlant as PartPlant on 
	Part.Company = PartPlant.Company
	and Part.PartNum = PartPlant.PartNum
left join erp.vendor on
	Vendor.VendorNum = PartPlant.VendorNum
where (Part.InActive = 0)
order by TotalCount desc

SELECT JH.Startdate, JH.PartNum,JP.JobNum, JP.ProdQty, JP.ReceivedQty, J
FROM erp.JobProd JP
INNER JOIN JobHead JH
ON JH.JobNum = JP.JobNum
where JH.prodqty < ReceivedQty  
order by JH.startdate desc

SELECT TOP (10) * from erp.jobhead

SELECT * FROM PartTran where jobnum = 'J090527'