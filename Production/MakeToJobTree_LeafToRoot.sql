WITH ANCHOR AS (
    -- Anchor member: starting point
    SELECT 
        JobNum,
        PartNum,
        ProdQty,
        OrderNum,
        OrderLine,
        OrderRelNum,
        TargetJobNum,
        TargetAssemblySeq,
        TargetMtlSeq,
        0 as lvl,
        JobNum as RootJobNum,          -- Track the root job number
        OrderNum as FinalOrderNum      -- Initialize FinalOrderNum
    FROM erp.JobProd
    WHERE JobNum LIKE 'U%2176'

    UNION ALL

    -- Recursive member: pass down FinalOrderNum and RootJobNum
    SELECT 
        jp.JobNum,
        jp.PartNum,
        jp.ProdQty,
        jp.OrderNum,
        jp.OrderLine,
        jp.OrderRelNum,
        jp.TargetJobNum,
        jp.TargetAssemblySeq,
        jp.TargetMtlSeq,
        A.lvl + 1,
        A.RootJobNum,                                 -- Keep the original root JobNum
        COALESCE(jp.OrderNum, A.FinalOrderNum) as FinalOrderNum  -- Carry down
    FROM ANCHOR A
    INNER JOIN erp.JobProd jp ON A.TargetJobNum = jp.JobNum
)

SELECT 
    A.*,
    F.FinalOrderNum as DeepestOrderNum
FROM ANCHOR A
INNER JOIN (
    SELECT RootJobNum, MAX(lvl) AS MaxLvl
    FROM ANCHOR
    GROUP BY RootJobNum
) MaxLevels
    ON A.RootJobNum = MaxLevels.RootJobNum
-- This join gets us the row with the deepest level per root
INNER JOIN ANCHOR F
    ON F.RootJobNum = MaxLevels.RootJobNum
    AND F.lvl = MaxLevels.MaxLvl

--ChatGPT

with [Anchor] as 
(select 
	[JobProd].[JobNum] as [JobProd_JobNum],
	[JobProd].[PartNum] as [JobProd_PartNum],
	[JobProd].[ProdQty] as [JobProd_ProdQty],
	[JobProd].[OrderNum] as [JobProd_OrderNum],
	[JobProd].[OrderLine] as [JobProd_OrderLine],
	[JobProd].[OrderRelNum] as [JobProd_OrderRelNum],
	[JobProd].[TargetJobNum] as [JobProd_TargetJobNum],
	[JobProd].[TargetAssemblySeq] as [JobProd_TargetAssemblySeq],
	[JobProd].[TargetMtlSeq] as [JobProd_TargetMtlSeq],
	(0) as [Calculated_lvl],
	(JobProd.JobNum) as [Calculated_RootJobNum],
	(JobProd.OrderNum) as [Calculated_FinalOrderNum]
from Erp.JobProd as JobProd
where (JobProd.JobNum like 'U%2176')

union all
select 
	[JobProd1].[JobNum] as [JobProd1_JobNum],
	[JobProd1].[PartNum] as [JobProd1_PartNum],
	[JobProd1].[ProdQty] as [JobProd1_ProdQty],
	[JobProd1].[OrderNum] as [JobProd1_OrderNum],
	[JobProd1].[OrderLine] as [JobProd1_OrderLine],
	[JobProd1].[OrderRelNum] as [JobProd1_OrderRelNum],
	[JobProd1].[TargetJobNum] as [JobProd1_TargetJobNum],
	[JobProd1].[TargetAssemblySeq] as [JobProd1_TargetAssemblySeq],
	[JobProd1].[TargetMtlSeq] as [JobProd1_TargetMtlSeq],
	(Anchor.Calculated_lvl+1) as [Calculated_lvl],
	[Anchor].[Calculated_RootJobNum] as [Calculated_RootJobNum],
	(COALESCE(JobProd1.OrderNum,Anchor.Calculated_FinalOrderNum)) as [Calculated_FinalOrderNum]
from  Anchor  as Anchor
inner join Erp.JobProd as JobProd1 on 
	Anchor.JobProd_TargetJobNum = JobProd1.JobNum)

select 
	[Anchor2].[Calculated_lvl] as [Calculated_lvl],
	[Anchor2].[Calculated_RootJobNum] as [Calculated_RootJobNum],
	[Anchor2].[JobProd_JobNum] as [JobProd_JobNum],
	[Anchor2].[JobProd_OrderLine] as [JobProd_OrderLine],
	[Anchor2].[JobProd_OrderNum] as [JobProd_OrderNum],
	[Anchor2].[JobProd_OrderRelNum] as [JobProd_OrderRelNum],
	[Anchor2].[JobProd_PartNum] as [JobProd_PartNum],
	[Anchor2].[JobProd_ProdQty] as [JobProd_ProdQty],
	[Anchor2].[JobProd_TargetAssemblySeq] as [JobProd_TargetAssemblySeq],
	[Anchor2].[JobProd_TargetJobNum] as [JobProd_TargetJobNum],
	[Anchor2].[JobProd_TargetMtlSeq] as [JobProd_TargetMtlSeq],
	[Anchor3].[Calculated_FinalOrderNum]
from  Anchor  as Anchor2
inner join  (select 
	[Anchor1].[Calculated_RootJobNum] as [Calculated_RootJobNum],
	(MAX(Anchor1.Calculated_lvl)) as [Calculated_MaxLvl]
from  Anchor  as Anchor1
group by [Anchor1].[Calculated_RootJobNum])  as Maxlevels on 
	Anchor2.Calculated_RootJobNum = Maxlevels.Calculated_RootJobNum
inner join  Anchor  as Anchor3 on 
	Anchor3.Calculated_RootJobNum = Maxlevels.Calculated_RootJobNum
	and Anchor3.Calculated_lvl = Maxlevels.Calculated_MaxLvl