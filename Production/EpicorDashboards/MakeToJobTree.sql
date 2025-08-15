/*
    Recursive CTE to build a job tree for a specific sales order, line, and release.
    - The [Base] CTE selects the root job(s) for the given order, line, and release.
    - The [Anchor] CTE recursively joins JobProd to find all jobs linked via TargetJobNum, incrementing the level for each recursion.
    - The final SELECT returns the job tree, including job numbers, part numbers, production quantities, order details, target job/assembly/material references, and job firm status, along with key job dates.
    - Results are ordered by the calculated level in the job tree.
    - Used for visualizing or analyzing the make-to-job structure for a given sales order in Epicor ERP.
*/
with [Base] as 
(select 
	(0) as [Calculated_lvl],
	[JobProd2].[JobNum] as [JobProd2_JobNum],
	[JobProd2].[PartNum] as [JobProd2_PartNum],
	[JobProd2].[ProdQty] as [JobProd2_ProdQty],
	[JobProd2].[OrderNum] as [JobProd2_OrderNum],
	[JobProd2].[OrderLine] as [JobProd2_OrderLine],
	[JobProd2].[OrderRelNum] as [JobProd2_OrderRelNum],
	[JobProd2].[TargetJobNum] as [JobProd2_TargetJobNum],
	[JobProd2].[TargetAssemblySeq] as [JobProd2_TargetAssemblySeq],
	[JobProd2].[TargetMtlSeq] as [JobProd2_TargetMtlSeq],
	[JobHead3].[JobFirm] as [JobHead3_JobFirm]
from Erp.JobProd as JobProd2
inner join Erp.JobHead as JobHead3 on 
	JobProd2.Company = JobHead3.Company
	and JobProd2.JobNum = JobHead3.JobNum
where (JobProd2.OrderNum = '2359381'  and JobProd2.OrderLine = '10'  and JobProd2.OrderRelNum = '1'))
 ,[Anchor] as 
(select 
	[Base].[Calculated_lvl] as [Calculated_lvl],
	[Base].[JobProd2_JobNum] as [JobProd2_JobNum],
	[Base].[JobProd2_PartNum] as [JobProd2_PartNum],
	[Base].[JobProd2_ProdQty] as [JobProd2_ProdQty],
	[Base].[JobProd2_OrderNum] as [JobProd2_OrderNum],
	[Base].[JobProd2_OrderLine] as [JobProd2_OrderLine],
	[Base].[JobProd2_OrderRelNum] as [JobProd2_OrderRelNum],
	[Base].[JobProd2_TargetJobNum] as [JobProd2_TargetJobNum],
	[Base].[JobProd2_TargetAssemblySeq] as [JobProd2_TargetAssemblySeq],
	[Base].[JobProd2_TargetMtlSeq] as [JobProd2_TargetMtlSeq],
	[Base].[JobHead3_JobFirm] as [JobHead3_JobFirm]
from  Base  as Base
union all
select 
	(Anchor.Calculated_lvl+1) as [Calculated_lvl01],
	[JobProd1].[JobNum] as [JobProd1_JobNum],
	[JobProd1].[PartNum] as [JobProd1_PartNum],
	[JobProd1].[ProdQty] as [JobProd1_ProdQty],
	[JobProd1].[OrderNum] as [JobProd1_OrderNum],
	[JobProd1].[OrderLine] as [JobProd1_OrderLine],
	[JobProd1].[OrderRelNum] as [JobProd1_OrderRelNum],
	[JobProd1].[TargetJobNum] as [JobProd1_TargetJobNum],
	[JobProd1].[TargetAssemblySeq] as [JobProd1_TargetAssemblySeq],
	[JobProd1].[TargetMtlSeq] as [JobProd1_TargetMtlSeq],
	[JobHead1].[JobFirm] as [JobHead1_JobFirm]
from  Anchor  as Anchor
inner join Erp.JobProd as JobProd1 on 
	Anchor.JobProd2_JobNum = JobProd1.TargetJobNum
inner join Erp.JobHead as JobHead1 on 
	JobProd1.Company = JobHead1.Company
	and JobProd1.JobNum = JobHead1.JobNum
where (JobProd1.TargetJobNum is not null))

select 
	[Anchor1].[Calculated_lvl] as [Calculated_lvl],
	[Anchor1].[JobProd2_JobNum] as [JobProd2_JobNum],
	[Anchor1].[JobProd2_PartNum] as [JobProd2_PartNum],
	[Anchor1].[JobProd2_OrderNum] as [JobProd2_OrderNum],
	[Anchor1].[JobProd2_OrderLine] as [JobProd2_OrderLine],
	[Anchor1].[JobProd2_OrderRelNum] as [JobProd2_OrderRelNum],
	[Anchor1].[JobProd2_ProdQty] as [JobProd2_ProdQty],
	[JobHead2].[ReqDueDate] as [JobHead2_ReqDueDate],
	[JobHead2].[StartDate] as [JobHead2_StartDate],
	[JobHead2].[DueDate] as [JobHead2_DueDate],
	[JobHead2].[JobFirm] as [JobHead2_JobFirm],
	[Anchor1].[JobProd2_PartNum] as [JobProd2_PartNum],
	[Anchor1].[JobProd2_TargetJobNum] as [JobProd2_TargetJobNum],
	[Anchor1].[JobProd2_TargetAssemblySeq] as [JobProd2_TargetAssemblySeq],
	[Anchor1].[JobProd2_TargetMtlSeq] as [JobProd2_TargetMtlSeq]
from  Anchor  as Anchor1
inner join Erp.JobHead as JobHead2 on 
	Anchor1.JobProd2_JobNum = JobHead2.JobNum
order by Anchor1.Calculated_lvl