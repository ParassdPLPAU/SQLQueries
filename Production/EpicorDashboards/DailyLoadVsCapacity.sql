/*
 * Disclaimer!!!
 * This is not a real query being executed, but a simplified version for general vision.
 * Executing it with any other tool may produce a different result.
 */
 
with [LoadCTE] as 
(select 
	[BaseLoad].[ResourceTimeUsed_Company] as [ResourceTimeUsed_Company],
	[BaseLoad].[ResourceTimeUsed_ResourceGrpID] as [ResourceTimeUsed_ResourceGrpID],
	[BaseLoad].[ResourceTimeUsed_JobNum] as [ResourceTimeUsed_JobNum],
	[BaseLoad].[ResourceTimeUsed_AssemblySeq] as [ResourceTimeUsed_AssemblySeq],
	[BaseLoad].[ResourceTimeUsed_OprSeq] as [ResourceTimeUsed_OprSeq],
	[BaseLoad].[ResourceTimeUsed_OpDtlSeq] as [ResourceTimeUsed_OpDtlSeq],
	[BaseLoad].[Calculated_LoadDate] as [Calculated_LoadDate],
	[BaseLoad].[Calculated_LoadDates] as [Calculated_LoadDates],
	[BaseLoad].[Calculated_LoadNum] as [Calculated_LoadNum],
	[BaseLoad].[Calculated_LoadHour] as [Calculated_LoadHour],
	[BaseLoad].[Calculated_LoadHours] as [Calculated_LoadHours],
	[BaseLoad].[ResourceTimeUsed_StartDate] as [ResourceTimeUsed_StartDate]
from  (select 
	[ResourceTimeUsed].[Company] as [ResourceTimeUsed_Company],
	[ResourceTimeUsed].[ResourceGrpID] as [ResourceTimeUsed_ResourceGrpID],
	[ResourceTimeUsed].[JobNum] as [ResourceTimeUsed_JobNum],
	[ResourceTimeUsed].[AssemblySeq] as [ResourceTimeUsed_AssemblySeq],
	[ResourceTimeUsed].[OprSeq] as [ResourceTimeUsed_OprSeq],
	[ResourceTimeUsed].[OpDtlSeq] as [ResourceTimeUsed_OpDtlSeq],
	(LEFT( ResourceTimeUsed.LoadDays, CHARINDEX( '~', ResourceTimeUsed.LoadDays + '~') - 1)) as [Calculated_LoadDate],
	(STUFF( ResourceTimeUsed.LoadDays, 1, CHARINDEX( '~', ResourceTimeUsed.LoadDays + '~'), '')) as [Calculated_LoadDates],
	(1) as [Calculated_LoadNum],
	(LEFT( ResourceTimeUsed.LoadHours, CHARINDEX( '~', ResourceTimeUsed.LoadHours + '~') - 1)) as [Calculated_LoadHour],
	(STUFF( ResourceTimeUsed.LoadHours, 1, CHARINDEX( '~', ResourceTimeUsed.LoadHours + '~'), '')) as [Calculated_LoadHours],
	[ResourceTimeUsed].[StartDate] as [ResourceTimeUsed_StartDate]
from Erp.ResourceTimeUsed as ResourceTimeUsed
where (ResourceTimeUsed.WhatIf = 0  and ResourceTimeUsed.LoadDays <> ''))  as BaseLoad
union all
select 
	[LoadCTE1].[ResourceTimeUsed_Company] as [ResourceTimeUsed_Company],
	[LoadCTE1].[ResourceTimeUsed_ResourceGrpID] as [ResourceTimeUsed_ResourceGrpID],
	[LoadCTE1].[ResourceTimeUsed_JobNum] as [ResourceTimeUsed_JobNum],
	[LoadCTE1].[ResourceTimeUsed_AssemblySeq] as [ResourceTimeUsed_AssemblySeq],
	[LoadCTE1].[ResourceTimeUsed_OprSeq] as [ResourceTimeUsed_OprSeq],
	[LoadCTE1].[ResourceTimeUsed_OpDtlSeq] as [ResourceTimeUsed_OpDtlSeq],
	(LEFT(LoadCTE1.Calculated_LoadDates, CHARINDEX( '~', LoadCTE1.Calculated_LoadDates + '~') - 1)) as [Calculated_LoadDate2],
	(STUFF( LoadCTE1.Calculated_LoadDates, 1, CHARINDEX( '~', LoadCTE1.Calculated_LoadDates + '~'), '')) as [Calculated_LoadDates2],
	(LoadCTE1.Calculated_LoadNum + 1) as [Calculated_LoadNum2],
	(LEFT(LoadCTE1.Calculated_LoadHours, CHARINDEX( '~', LoadCTE1.Calculated_LoadHours + '~') - 1)) as [Calculated_LoadHour2],
	(STUFF( LoadCTE1.Calculated_LoadHours, 1, CHARINDEX( '~', LoadCTE1.Calculated_LoadHours + '~'), '')) as [Calculated_LoadHours2],
	[LoadCTE1].[ResourceTimeUsed_StartDate] as [ResourceTimeUsed_StartDate]
from  LoadCTE  as LoadCTE1
where (LoadCTE1.Calculated_LoadDates <> ''  and LoadCTE1.Calculated_LoadNum <= 100))
 ,[Anchor] as 
(select 
	[JobProd].[JobNum] as [JobProd_JobNum],
	[JobProd].[OrderNum] as [JobProd_OrderNum],
	[JobProd].[OrderLine] as [JobProd_OrderLine],
	[JobProd].[OrderRelNum] as [JobProd_OrderRelNum],
	[JobProd].[TargetJobNum] as [JobProd_TargetJobNum],
	(0) as [Calculated_lvl],
	(JobProd.JobNum) as [Calculated_JobNum]
from Erp.JobProd as JobProd
inner join  LoadCTE  as LoadCTE2 on 
	JobProd.JobNum = LoadCTE2.ResourceTimeUsed_JobNum
union all
select 
	[JobProd1].[JobNum] as [JobProd1_JobNum],
	(COALESCE(JobProd1.OrderNum, Anchor.JobProd_OrderNum)) as [Calculated_FinalOrderNum],
	(COALESCE(JobProd1.OrderLine, Anchor.JobProd_OrderLine)) as [Calculated_FinalOrderLine],
	(COALESCE(JobProd1.OrderRelNum,Anchor.JobProd_OrderRelNum)) as [Calculated_FinalOrderRel],
	[JobProd1].[TargetJobNum] as [JobProd1_TargetJobNum],
	(Anchor.Calculated_lvl+1) as [Calculated_lvl],
	[Anchor].[Calculated_JobNum] as [Calculated_JobNum]
from Erp.JobProd as JobProd1
inner join  Anchor  as Anchor on 
	JobProd1.JobNum = Anchor.JobProd_TargetJobNum)
 ,[AnchorSummary] as 
(select 
	[Anchor1].[Calculated_JobNum] as [Calculated_JobNum],
	(MAX(Anchor1.Calculated_lvl)) as [Calculated_MaxLevel],
	(MAX(Anchor1.JobProd_OrderNum)) as [Calculated_FinalOrderNum],
	(MAX(Anchor1.JobProd_OrderLine)) as [Calculated_FinalOrderLine],
	(MAX(Anchor1.JobProd_OrderRelNum)) as [Calculated_FinalOrderRelNum]
from  Anchor  as Anchor1
group by [Anchor1].[Calculated_JobNum])

select 
	[LoadCTE].[ResourceTimeUsed_Company] as [ResourceTimeUsed_Company],
	[LoadCTE].[ResourceTimeUsed_ResourceGrpID] as [ResourceTimeUsed_ResourceGrpID],
	[LoadCTE].[ResourceTimeUsed_JobNum] as [ResourceTimeUsed_JobNum],
	[LoadCTE].[ResourceTimeUsed_AssemblySeq] as [ResourceTimeUsed_AssemblySeq],
	[LoadCTE].[ResourceTimeUsed_OprSeq] as [ResourceTimeUsed_OprSeq],
	[LoadCTE].[ResourceTimeUsed_OpDtlSeq] as [ResourceTimeUsed_OpDtlSeq],
	[LoadCTE].[Calculated_LoadDate] as [Calculated_LoadDate],
	[LoadCTE].[Calculated_LoadDates] as [Calculated_LoadDates],
	[LoadCTE].[Calculated_LoadNum] as [Calculated_LoadNum],
	[LoadCTE].[Calculated_LoadHours] as [Calculated_LoadHours],
	[LoadCTE].[ResourceTimeUsed_StartDate] as [ResourceTimeUsed_StartDate],
	(LoadCTE.Calculated_LoadNum - 1) as [Calculated_LoadNumFactor],
	(Dateadd(dd, LoadCTE.Calculated_LoadNum-1, LoadCTE.ResourceTimeUsed_StartDate)) as [Calculated_LoadStartDate],
	[LoadCTE].[Calculated_LoadHour] as [Calculated_LoadHour],
	(convert(varchar, LoadCTE.Calculated_LoadHour)) as [Calculated_DecLoadHour],
	[JobHead].[PartNum] as [JobHead_PartNum],
	[JobHead].[JobFirm] as [JobHead_JobFirm],
	[AnchorSummary].[Calculated_FinalOrderNum] as [Calculated_FinalOrderNum],
	[AnchorSummary].[Calculated_FinalOrderLine] as [Calculated_FinalOrderLine],
	[AnchorSummary].[Calculated_FinalOrderRelNum] as [Calculated_FinalOrderRelNum],
	[AnchorSummary].[Calculated_MaxLevel] as [Calculated_MaxLevel]
from  LoadCTE  as LoadCTE
inner join Erp.JobHead as JobHead on 
	LoadCTE.ResourceTimeUsed_Company = JobHead.Company
	and LoadCTE.ResourceTimeUsed_JobNum = JobHead.JobNum
left outer join  AnchorSummary  as AnchorSummary on 
	LoadCTE.ResourceTimeUsed_JobNum = AnchorSummary.Calculated_JobNum
where (LoadCTE.Calculated_LoadNum <> 0)
--and ResourceTimeUsed_JobNum LIKE'U%1128'