WITH BASE AS (
SELECT 
	[JobHead].[Company],
	[JobHead].[JobNum],
	[JobHead].[StartDate],
	[JobHead].[PartNum],
	[JobHead].[PartDescription],
	[JobHead].[ProdQty],
	[JobHead].[Plant],
	[JobHead].[PersonID],
	[JobHead].[JobFirm],
	((case when (JobHead.PersonID = 'ASSY_RCK' or JobHead.PersonID = 'RACKELEC') then 7 else 14 end)) as [Days_To_Firm]
FROM JobHead
), BASE_2 AS (
select 
	JobHead.[JobNum] as [JobHead_JobNum],
	JobHead.[PartNum],
	JobHead.[PartDescription] as [JobHead_PartDescription],
	JobHead.[ProdQty] as [JobHead_ProdQty],
	JobHead.[Plant],
	JobHead.[PersonID] as [JobHead_PersonID],
	JobFirm,
	dateadd(day, (- Days_To_Firm - PartPlant.PlanTimeFence), JobHead.StartDate) AS 'Date_To_Firm',
	JobHead.[StartDate] as [JobHead_StartDate],
	PartPlant.PlanTimeFence
from BASE as JobHead
inner join Erp.PartPlant as PartPlant on 
	JobHead.Company = PartPlant.Company
	and JobHead.PartNum = PartPlant.PartNum
	and JobHead.Plant = PartPlant.Plant
where (JobHead.JobFirm = 0)
)
SELECT *,
	CASE 
		WHEN Date_To_Firm > (CONVERT(date, GETDATE())) AND JobFirm = 1
		THEN 'Premature firming'
		WHEN Date_To_Firm = (CONVERT(date, GETDATE())) AND JobFirm = 0
		THEN 'To be Firmed today'
		WHEN Date_To_Firm < (CONVERT(date, GETDATE())) AND JobFirm = 0
		THEN 'Late to firm'
	ELSE 'No Action Required'
	END AS 'FirmingStatus'
FROM BASE_2
ORDER BY Date_To_Firm asc;