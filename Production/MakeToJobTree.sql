WITH ANCHOR  AS (
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
        0 as lvl
    FROM erp.JobProd
	--WHERE OrderNum = '2365262'
	--AND OrderLine = '1'
	--AND OrderRelNum = '1'

    UNION ALL

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
        A.lvl + 1
    FROM ANCHOR A
    INNER JOIN erp.JobProd jp ON jp.TargetJobNum = A.JobNum
	WHERE jp.TargetJobNum IS NOT NULL
)
SELECT * FROM ANCHOR
OPTION (MAXRECURSION 100);

--BAQ which doesnt work in Epicor
with [Anchor] as 
(select 
	[JobProd].[JobNum] as [JobProd_JobNum],
	[JobHead].[StartDate] as [JobHead_StartDate],
	[JobHead].[JobReleased] as [JobHead_JobReleased],
	[JobHead].[DueDate] as [JobHead_DueDate],
	[JobHead].[ReqDueDate] as [JobHead_ReqDueDate],
	[JobProd].[PartNum] as [JobProd_PartNum],
	[JobHead].[PartDescription] as [JobHead_PartDescription],
	[JobProd].[ProdQty] as [JobProd_ProdQty],
	[JobHead].[JobCompletionDate] as [JobHead_JobCompletionDate],
	[JobProd].[OrderNum] as [JobProd_OrderNum],
	[JobProd].[OrderLine] as [JobProd_OrderLine],
	[JobProd].[OrderRelNum] as [JobProd_OrderRelNum],
	[JobHead3].[StartDate] as [JobHead3_StartDate],
	[JobProd].[TargetJobNum] as [JobProd_TargetJobNum],
	[JobProd].[TargetAssemblySeq] as [JobProd_TargetAssemblySeq],
	[JobProd].[TargetMtlSeq] as [JobProd_TargetMtlSeq],
	(0) as [Calculated_lvl],
	[JobHead].[JobNum] as [JobHead_JobNum],
	[JobHead].[PartNum] as [JobHead_PartNum],
	[JobHead].[RevisionNum] as [JobHead_RevisionNum],
	[JobHead].[JobCode] as [JobHead_JobCode],
	[JobHead].[JobFirm] as [JobHead_JobFirm]
from Erp.JobProd as JobProd
inner join Erp.JobHead as JobHead on 
	JobProd.Company = JobHead.Company
	and JobProd.JobNum = JobHead.JobNum
left join Erp.JobHead as JobHead3 on 
	JobProd.Company = JobHead3.Company
	and JobProd.TargetJobNum = JobHead3.JobNum
where (JobProd.OrderNum = '2365260'  and JobProd.OrderLine = '1'  and JobProd.OrderRelNum = '1')

union all
select 
	[JobProd1].[JobNum] as [JobProd1_JobNum],
	[JobHead1].[StartDate] as [JobHead1_StartDate],
	[JobHead1].[JobReleased] as [JobHead1_JobReleased],
	[JobHead1].[DueDate] as [JobHead1_DueDate],
	[JobHead1].[ReqDueDate] as [JobHead1_ReqDueDate],
	[JobProd1].[PartNum] as [JobProd1_PartNum],
	[JobHead1].[PartDescription] as [JobHead1_PartDescription],
	[JobProd1].[ProdQty] as [JobProd1_ProdQty],
	[JobHead1].[JobCompletionDate] as [JobHead1_JobCompletionDate],
	[JobProd1].[OrderNum] as [JobProd1_OrderNum],
	[JobProd1].[OrderLine] as [JobProd1_OrderLine],
	[JobProd1].[OrderRelNum] as [JobProd1_OrderRelNum],
	[JobHead4].[StartDate] as [JobHead4_StartDate],
	[JobProd1].[TargetJobNum] as [JobProd1_TargetJobNum],
	[JobProd1].[TargetAssemblySeq] as [JobProd1_TargetAssemblySeq],
	[JobProd1].[TargetMtlSeq] as [JobProd1_TargetMtlSeq],
	(Anchor.Calculated_lvl+1) as [Calculated_lvl01],
	[JobHead1].[JobNum] as [JobHead1_JobNum],
	[JobHead1].[PartNum] as [JobHead1_PartNum],
	[JobHead1].[RevisionNum] as [JobHead1_RevisionNum],
	[JobHead1].[JobCode] as [JobHead1_JobCode],
	[JobHead1].[JobFirm] as [JobHead1_JobFirm]
from  Anchor  as Anchor
inner join Erp.JobProd as JobProd1 on 
	Anchor.JobProd_JobNum = JobProd1.TargetJobNum
inner join Erp.JobHead as JobHead1 on 
	JobProd1.Company = JobHead1.Company
	and JobProd1.JobNum = JobHead1.JobNum
inner join Erp.JobHead as JobHead4 on 
	JobProd1.Company = JobHead4.Company
	and JobProd1.TargetJobNum = JobHead4.JobNum
where (JobProd1.TargetJobNum is not null))

select 
	[Anchor1].[Calculated_lvl] as [Calculated_lvl],
	[Anchor1].[JobProd_JobNum] as [JobProd_JobNum],
	[Anchor1].[JobHead_StartDate] as [JobHead_StartDate],
	[Anchor1].[JobHead_JobReleased] as [JobHead_JobReleased],
	[Anchor1].[JobHead_DueDate] as [JobHead_DueDate],
	[Anchor1].[JobHead_ReqDueDate] as [JobHead_ReqDueDate],
	[Anchor1].[JobHead_JobCompletionDate] as [JobHead_JobCompletionDate],
	[Anchor1].[JobHead_PartNum] as [JobHead_PartNum],
	[Anchor1].[JobHead_RevisionNum] as [JobHead_RevisionNum],
	[Anchor1].[JobHead_PartDescription] as [JobHead_PartDescription],
	[Anchor1].[JobProd_OrderNum] as [JobProd_OrderNum],
	[Anchor1].[JobProd_OrderLine] as [JobProd_OrderLine],
	[Anchor1].[JobProd_OrderRelNum] as [JobProd_OrderRelNum],
	[Anchor1].[JobProd_PartNum] as [JobProd_PartNum],
	[Anchor1].[JobProd_ProdQty] as [JobProd_ProdQty],
	[Anchor1].[JobHead3_StartDate] as [JobHead3_StartDate],
	[Anchor1].[JobProd_TargetJobNum] as [JobProd_TargetJobNum],
	[Anchor1].[JobProd_TargetAssemblySeq] as [JobProd_TargetAssemblySeq],
	[Anchor1].[JobProd_TargetMtlSeq] as [JobProd_TargetMtlSeq],
	[JobHead2].[JobNum] as [JobHead2_JobNum],
	[JobHead2].[PartNum] as [JobHead2_PartNum],
	[JobHead2].[RevisionNum] as [JobHead2_RevisionNum],
	[JobHead2].[JobCode] as [JobHead2_JobCode],
	[Anchor1].[JobHead_JobCode] as [JobHead_JobCode],
	[JobHead2].[JobFirm] as [JobHead2_JobFirm]
from  Anchor  as Anchor1
inner join Erp.JobHead as JobHead2 on 
	Anchor1.JobProd_JobNum = JobHead2.JobNum

--Find SO from Job Number
WITH ANCHOR  AS (
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
        0 as lvl
    FROM erp.JobProd
	WHERE JobNum LIKE 'U%2176'

    UNION ALL

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
        A.lvl + 1
    FROM ANCHOR A
    INNER JOIN erp.JobProd jp ON A.TargetJobNum = JP.JobNum
	--WHERE jp.TargetJobNum IS NOT NULL
)
SELECT * FROM ANCHOR
OPTION (MAXRECURSION 100);

--ChatGPT
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
    --WHERE JobNum LIKE 'U%2176'
	--WHERE OrderNum = '2365262'
	--AND OrderLine = '4'
	--AND OrderRelNum = '1'

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

-- Now, identify the final (deepest) OrderNum for each root JobNum
, FinalOrderPerRoot AS (
    SELECT 
        RootJobNum,
        FinalOrderNum as FinalOrderNum,
        MAX(lvl) as MaxLevel
    FROM ANCHOR
    GROUP BY RootJobNum, FinalOrderNum
)
--SELECT * FROM FinalOrderPerRoot
-- Join back to every row
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

OPTION (MAXRECURSION 100);