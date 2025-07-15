
/*
    MfgPartShortage.sql

    This query identifies manufacturing part shortages for the GLENDN plant by analyzing demand, supply, and job data.
    It calculates running balances, safety minimums, and shortage days, and correlates part demand records with job suggestions and firmed jobs.
    The output includes planner assignments, shortage metrics, and relevant job/order details for parts that are below safety stock thresholds.

    Key Features:
    - Computes running supply/demand and safety minimums for each part.
    - Flags records where supply is below safety minimum ("Under").
    - Associates each shortage with the earliest unfirmed and firmed job suggestions.
    - Calculates shortage days between demand due dates and job due dates.
    - Filters for first shortage records in both past and future timeframes.

    Tables Used:
    - Erp.PartDtl, Erp.PartPlant, Erp.PartWhse, Erp.Warehse, Erp.JobHead

    Parameters:
    - @FirstDayOfMonth: Start date for demand records.
    - @Today: Current date for filtering jobs.

    Output Columns:
    - Planner IDs, part numbers, running balances, shortage days, job/order details, and shortage classification.

    Note:
    This is a simplified query for general vision and may produce different results if executed outside its intended environment.
*/

 
select 
	[FirstRecordJobSuggestion].[JobHead_PersonID] as [JobHead_PersonID],
	[FirstOpenJobs].[JobHead1_PersonID] as [JobHead1_PersonID],
	((case when FirstOpenJobs.JobHead1_PersonID <> '' then FirstOpenJobs.JobHead1_PersonID else FirstRecordJobSuggestion.JobHead_PersonID end)) as [Calculated_Planner_ID],
	[Under_Count_Index].[PartDtl_PartNum] as [PartDtl_PartNum],
	[Under_Count_Index].[Calculated_Row_Count] as [Calculated_Row_Count],
	[Under_Count_Index].[PartDtl_DueDate] as [PartDtl_DueDate],
	[Under_Count_Index].[Calculated_RunningBalance] as [Calculated_RunningBalance],
	[Under_Count_Index].[Calculated_SafetyMinQty] as [Calculated_SafetyMinQty],
	[Under_Count_Index].[Calculated_BelowOverSafety] as [Calculated_BelowOverSafety],
	[Under_Count_Index].[Calculated_PastFuture] as [Calculated_PastFuture],
	[Under_Count_Index].[PartDtl_Company] as [PartDtl_Company],
	[Under_Count_Index].[Calculated_EarlyLate_Index] as [Calculated_EarlyLate_Index],
	[Under_Count_Index].[Calculated_FirstRecord] as [Calculated_FirstRecord],
	[Under_Count_Index].[PartDtl_OrderNum] as [PartDtl_OrderNum],
	[Under_Count_Index].[PartDtl_JobNum] as [PartDtl_JobNum],
	[FirstRecordJobSuggestion].[JobHead_DueDate] as [JobHead_DueDate],
	[FirstRecordJobSuggestion].[JobHead_ProdQty] as [JobHead_ProdQty],
	[FirstRecordJobSuggestion].[JobHead_JobNum] as [JobHead_JobNum],
	(datediff(day,Under_Count_Index.PartDtl_DueDate, FirstRecordJobSuggestion.JobHead_DueDate)) as [Calculated_ShortageDays],
	[Under_Count_Index].[PartPlant2_MfgLotSize] as [PartPlant2_MfgLotSize],
	[FirstOpenJobs].[JobHead1_JobNum] as [JobHead1_JobNum],
	[FirstOpenJobs].[JobHead1_DueDate] as [JobHead1_DueDate],
	[FirstOpenJobs].[JobHead1_ProdQty] as [JobHead1_ProdQty],
	(datediff(day,Under_Count_Index.PartDtl_DueDate, FirstOpenJobs.JobHead1_DueDate)) as [Calculated_Firmed_Shortage_Days]
from  (select 
	[RunningBalanceTimePhase].[PartDtl_PartNum] as [PartDtl_PartNum],
	[RunningBalanceTimePhase].[Calculated_Row_Count] as [Calculated_Row_Count],
	[RunningBalanceTimePhase].[PartDtl_DueDate] as [PartDtl_DueDate],
	[RunningBalanceTimePhase].[Calculated_RunningBalance] as [Calculated_RunningBalance],
	[RunningBalanceTimePhase].[Calculated_SafetyMinQty] as [Calculated_SafetyMinQty],
	[RunningBalanceTimePhase].[Calculated_BelowOverSafety] as [Calculated_BelowOverSafety],
	[RunningBalanceTimePhase].[Calculated_PastFuture] as [Calculated_PastFuture],
	[RunningBalanceTimePhase].[PartDtl_Company] as [PartDtl_Company],
	((case when RunningBalanceTimePhase.Calculated_PastFuture = 'Past' then  max(RunningBalanceTimePhase.Calculated_Row_Count) OVER (Partition by RunningBalanceTimePhase.PartDtl_PartNum, RunningBalanceTimePhase.Calculated_PastFuture, RunningBalanceTimePhase.PartDtl_Company Order by RunningBalanceTimePhase.PartDtl_PartNum) else    min(RunningBalanceTimePhase.Calculated_Row_Count) OVER (Partition by RunningBalanceTimePhase.PartDtl_PartNum, RunningBalanceTimePhase.Calculated_PastFuture, RunningBalanceTimePhase.PartDtl_Company Order by RunningBalanceTimePhase.PartDtl_PartNum)  end)) as [Calculated_EarlyLate_Index],
	(case      when  RunningBalanceTimePhase.Calculated_Row_Count = EarlyLate_Index and  RunningBalanceTimePhase.Calculated_PastFuture = 'Past'  then 'First-Past'     when  RunningBalanceTimePhase.Calculated_Row_Count = EarlyLate_Index and  RunningBalanceTimePhase.Calculated_PastFuture = 'Future'then 'First-Future'     else  'N/A' end) as [Calculated_FirstRecord],
	[RunningBalanceTimePhase].[PartPlant1_Plant] as [PartPlant1_Plant],
	[RunningBalanceTimePhase].[PartPlant2_MfgLotSize] as [PartPlant2_MfgLotSize],
	[RunningBalanceTimePhase].[PartDtl_OrderNum] as [PartDtl_OrderNum],
	[RunningBalanceTimePhase].[PartDtl_JobNum] as [PartDtl_JobNum]
from  (select 
	[TimePhaseDueDate].[PartDtl_PartNum] as [PartDtl_PartNum],
	[TimePhaseDueDate].[Calculated_Row_Count] as [Calculated_Row_Count],
	[TimePhaseDueDate].[PartDtl_DueDate] as [PartDtl_DueDate],
	[TimePhaseDueDate].[Calculated_QtyOHRunningSupply] as [Calculated_QtyOHRunningSupply],
	[TimePhaseDueDate].[Calculated_DemandQty] as [Calculated_DemandQty],
	(RunningSupply - RunningDemand) as [Calculated_RunningBalance],
	[TimePhaseDueDate].[Calculated_SafetyMinQty] as [Calculated_SafetyMinQty],
	((case when (RunningSupply - RunningDemand) >= TimePhaseDueDate.Calculated_SafetyMinQty then 'Over' else 'Under' end)) as [Calculated_BelowOverSafety],
	((case when TimePhaseDueDate.PartDtl_DueDate < Constants.Today then 'Past' else 'Future' end)) as [Calculated_PastFuture],
	(ISNULL(sum(TimePhaseDueDate.Calculated_QtyOHRunningSupply) OVER (Partition by TimePhaseDueDate.PartDtl_PartNum Order by TimePhaseDueDate.PartDtl_DueDate),0)) as [Calculated_RunningSupply],
	(sum(TimePhaseDueDate.Calculated_DemandQty) OVER (Partition by TimePhaseDueDate.PartDtl_PartNum Order by TimePhaseDueDate.PartDtl_DueDate)) as [Calculated_RunningDemand],
	[TimePhaseDueDate].[PartDtl_Company] as [PartDtl_Company],
	[TimePhaseDueDate].[PartPlant1_Plant] as [PartPlant1_Plant],
	[TimePhaseDueDate].[PartPlant2_MfgLotSize] as [PartPlant2_MfgLotSize],
	[TimePhaseDueDate].[PartDtl_OrderNum] as [PartDtl_OrderNum],
	[TimePhaseDueDate].[PartDtl_JobNum] as [PartDtl_JobNum]
from  (select 
	[PartDetailDemand_Supply1].[PartDtl_Company] as [PartDtl_Company],
	[PartDetailDemand_Supply1].[PartDtl_PartNum] as [PartDtl_PartNum],
	[PartDetailDemand_Supply1].[PartDtl_Type] as [PartDtl_Type],
	[PartDetailDemand_Supply1].[PartDtl_DueDate] as [PartDtl_DueDate],
	[PartDetailDemand_Supply1].[PartDtl_RequirementFlag] as [PartDtl_RequirementFlag],
	[PartDetailDemand_Supply1].[PartPlant1_Plant] as [PartPlant1_Plant],
	[PartDetailDemand_Supply1].[PartDtl_Quantity] as [PartDtl_Quantity],
	[PartDetailDemand_Supply1].[PartDtl_SourceFile] as [PartDtl_SourceFile],
	[PartDetailDemand_Supply1].[Calculated_DemandQty] as [Calculated_DemandQty],
	[PartDetailDemand_Supply1].[Calculated_SupplyQty] as [Calculated_SupplyQty],
	[PartWhseQtyOH1].[Calculated_Tota_Qty_OH] as [Calculated_Tota_Qty_OH],
	((case when Row_Count = 1 then ISNULL(PartWhseQtyOH1.Calculated_Tota_Qty_OH,0) + PartDetailDemand_Supply1.Calculated_SupplyQty else PartDetailDemand_Supply1.Calculated_SupplyQty end)) as [Calculated_QtyOHRunningSupply],
	(ROW_NUMBER() OVER(PARTITION BY PartDetailDemand_Supply1.PartDtl_PartNum, PartDetailDemand_Supply1.PartDtl_Company  Order by PartDetailDemand_Supply1.PartDtl_DueDate ASC)) as [Calculated_Row_Count],
	(sum(PartDetailDemand_Supply1.Calculated_DemandQty) OVER(Partition by PartDetailDemand_Supply1.PartDtl_PartNum, PartDetailDemand_Supply1.PartDtl_Company Order by PartDetailDemand_Supply1.PartDtl_DueDate)) as [Calculated_RunningDemand],
	(sum(PartDetailDemand_Supply1.Calculated_SupplyQty) OVER(Partition by PartDetailDemand_Supply1.PartDtl_PartNum, PartDetailDemand_Supply1.PartDtl_Company Order by PartDetailDemand_Supply1.PartDtl_DueDate)) as [Calculated_RunningSupply],
	(PartPlant2.SafetyQty + PartPlant2.MinimumQty) as [Calculated_SafetyMinQty],
	[PartPlant2].[MfgLotSize] as [PartPlant2_MfgLotSize],
	[PartDetailDemand_Supply1].[PartDtl_OrderNum] as [PartDtl_OrderNum],
	[PartDetailDemand_Supply1].[PartDtl_JobNum] as [PartDtl_JobNum]
from  (select 
	[PartDtl].[PartNum] as [PartDtl_PartNum],
	[PartDtl].[Type] as [PartDtl_Type],
	[PartDtl].[DueDate] as [PartDtl_DueDate],
	[PartDtl].[RequirementFlag] as [PartDtl_RequirementFlag],
	[PartDtl].[Quantity] as [PartDtl_Quantity],
	[PartDtl].[SourceFile] as [PartDtl_SourceFile],
	[PartPlant1].[Plant] as [PartPlant1_Plant],
	[PartPlant1].[PlanTimeFence] as [PartPlant1_PlanTimeFence],
	(Constants.Today + PartPlant1.PlanTimeFence) as [Calculated_TFDueDate],
	((case when PartDtl.DueDate < TFDueDate then 'PastDue' else 'Due or NotDue' end)) as [Calculated_OverDueDate],
	((case when PartDtl.RequirementFlag = 1 then PartDtl.Quantity else 0 end)) as [Calculated_DemandQty],
	((case when PartDtl.RequirementFlag = 0 then PartDtl.Quantity else 0 end)) as [Calculated_SupplyQty],
	[PartDtl].[Company] as [PartDtl_Company],
	[PartDtl].[JobNum] as [PartDtl_JobNum],
	[PartDtl].[OrderNum] as [PartDtl_OrderNum]
from Erp.PartDtl as PartDtl
inner join Erp.PartPlant as PartPlant1 on 
	PartDtl.Company = PartPlant1.Company
	and PartDtl.PartNum = PartPlant1.PartNum
	and PartDtl.Plant = PartPlant1.Plant
	and ( PartPlant1.Plant = 'GLENDN'  and PartPlant1.SourceType = 'M'  )

where (PartDtl.DueDate >= @FirstDayOfMonth  and (PartDtl.SourceFile = 'OR'  or PartDtl.SourceFile = 'JM'  or PartDtl.SourceFile = 'TO'  or PartDtl.SourceFile = 'JH' )))  as PartDetailDemand_Supply1
inner join Erp.PartPlant as PartPlant2 on 
	PartDetailDemand_Supply1.PartDtl_PartNum = PartPlant2.PartNum
	and PartDetailDemand_Supply1.PartPlant1_Plant = PartPlant2.Plant
left outer join  (select 
	[PartWhse].[PartNum] as [PartWhse_PartNum],
	[Warehse].[Plant] as [Warehse_Plant],
	(SUM(PartWhse.OnHandQty)) as [Calculated_Tota_Qty_OH]
from Erp.PartWhse as PartWhse
inner join Erp.Warehse as Warehse on 
	PartWhse.Company = Warehse.Company
	and PartWhse.WarehouseCode = Warehse.WarehouseCode
	and ( Warehse.Plant = 'GLENDN'  )

where (PartWhse.OnHandQty <> 0)
group by [PartWhse].[PartNum],
	[Warehse].[Plant])  as PartWhseQtyOH1 on 
	PartDetailDemand_Supply1.PartDtl_PartNum = PartWhseQtyOH1.PartWhse_PartNum
	and PartDetailDemand_Supply1.PartPlant1_Plant = PartWhseQtyOH1.Warehse_Plant)  as TimePhaseDueDate)  as RunningBalanceTimePhase
where (RunningBalanceTimePhase.Calculated_BelowOverSafety = 'Under'))  as Under_Count_Index
left outer join  (select 
	[JobSuggestion].[JobHead_JobNum] as [JobHead_JobNum],
	[JobSuggestion].[JobHead_PartNum] as [JobHead_PartNum],
	[JobSuggestion].[JobHead_DueDate] as [JobHead_DueDate],
	[JobSuggestion].[Calculated_PartNoRowCount] as [Calculated_PartNoRowCount],
	[JobSuggestion].[JobHead_ProdQty] as [JobHead_ProdQty],
	[JobSuggestion].[JobHead_PersonID] as [JobHead_PersonID]
from  (select 
	[JobHead].[JobNum] as [JobHead_JobNum],
	[JobHead].[PartNum] as [JobHead_PartNum],
	[JobHead].[DueDate] as [JobHead_DueDate],
	(ROW_NUMBER() OVER(PARTITION BY JobHead.PartNum ORDER BY JobHead.DueDate ASC)) as [Calculated_PartNoRowCount],
	[JobHead].[ProdQty] as [JobHead_ProdQty],
	[JobHead].[PersonID] as [JobHead_PersonID]
from Erp.JobHead as JobHead
where (JobHead.JobFirm = false  and JobHead.Plant = 'GLENDN'))  as JobSuggestion
where (JobSuggestion.Calculated_PartNoRowCount = 1))  as FirstRecordJobSuggestion on 
	Under_Count_Index.PartDtl_PartNum = FirstRecordJobSuggestion.JobHead_PartNum
left outer join  (select 
	[JobHead1].[Company] as [JobHead1_Company],
	[JobHead1].[JobNum] as [JobHead1_JobNum],
	[JobHead1].[PartNum] as [JobHead1_PartNum],
	[JobHead1].[ProdQty] as [JobHead1_ProdQty],
	[JobHead1].[DueDate] as [JobHead1_DueDate],
	(ROW_NUMBER() OVER(PARTITION BY JobHead1.PartNum ORDER BY JobHead1.DueDate ASC)) as [Calculated_Count_Index],
	[JobHead1].[PersonID] as [JobHead1_PersonID]
from Erp.JobHead as JobHead1
where (JobHead1.JobFirm = true  and JobHead1.JobComplete = false  and JobHead1.DueDate >= @Today))  as FirstOpenJobs on 
	Under_Count_Index.PartDtl_Company = FirstOpenJobs.JobHead1_Company
	and Under_Count_Index.PartDtl_PartNum = FirstOpenJobs.JobHead1_PartNum
	and ( FirstOpenJobs.Calculated_Count_Index = 1  )

where (Under_Count_Index.Calculated_FirstRecord = 'First-Past'  or Under_Count_Index.Calculated_FirstRecord = 'First-Future')