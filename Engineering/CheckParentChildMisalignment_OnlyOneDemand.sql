SELECT 
    ParentJob.JobNum AS ParentJobNum,
    ChildJob.JobNum AS ChildJobNum,
    ParentJob.PartNum AS ParentPartNum,
    ChildJob.PartNum AS ChildPartNum,
    ParentJob.StartDate AS ParentJobStartDate,
	ParentJob.ReqDueDate AS ParentJobReqDueDate,
	ParentJob.DueDate AS ParentJobDueDate,
    ChildJob.ReqDueDate AS ChildJobReqDueDate,
	ChildJob.DueDate AS ChildJobDueDate
FROM 
    JobHead AS ParentJob
JOIN 
    erp.JobMtl AS Material ON ParentJob.JobNum = Material.JobNum
JOIN 
    JobHead AS ChildJob ON Material.PartNum = ChildJob.PartNum
WHERE 
    (ChildJob.ReqDueDate > ParentJob.StartDate
OR ChildJob.DueDate > ParentJob.StartDate)
AND (ParentJob.JobFirm = 0
AND ChildJob.JobFirm = 0)
--script does not account for one day in receiving

SELECT * FROM erp.PartDtl WHERE RequirementFlag = 1 AND DueDate < '2024-09-20'

--PartNum = 'A-A4482-04'

SELECT * FROM JobHead WHERE DueDate > '2025-03-26' and JobClosed = 1

BEGIN Transaction;
UPDATE [PLP_PILOT].[erp].Part 
SET Constrained = 1
WHERE PartNum IN (
SELECT Part.PartNum,Constrained,SafetyQty,PartPlant.TotMfgLeadTimeSys--PartPlant.LeadTime
FROM PartPlant
INNER JOIN Part
ON Part.PartNum = PartPlant.PartNum
WHERE Plant = 'GLENDN'
AND PartPlant.SafetyQty=0
--AND PartPlant.TotMfgLeadTimeSys > 7
AND TypeCode = 'M'
AND Part.Inactive = 0 order by partnum-- order by PartPlant.TotMfgLeadTimeSys desc
)

COMMIT


select * from [PLP_LIVE].erp.[Part] where constrained = 1


SELECT * FROM Part

WHERE PartNum IN (
SELECT [PLP_LIVE].[erp].Part.PartNum FROM [PLP_LIVE].[erp].Part
WHERE Constrained = 1
)

SELECT PartNum, PlanTimeFence FROM PartPlant WHERE Plant = 'GLENDN'

SELECT * FROM erp.JobHead where jobfirm = 1  and jobclosed = 0 Order By duedate desc 

BEGIN TRANSACTION;
UPDATE [PLP_PILOT].[erp].PartPlant
SET MultiLevelCTP = 1
WHERE PartNum IN (
SELECT P.PartNum, PP.ReceiveTime, PP.KitTime,PP.SourceType
FROM erp.part P 
INNER JOIN PartPlant PP
ON PP.PartNum = P.PartNum
where P.inactive = 0 
AND PP.MultiLevelCTP = 0
AND P.PartNum LIKE 'A-%'
AND PP.SourceType = 'M')
COMMIT;

BEGIN TRANSACTION;
UPDATE [PLP_PILOT].[erp].PartPlant
SET mfglotsize = 1
WHERE PartNum IN
(SELECT P.PartNum, PP.ReceiveTime, PP.KitTime,PP.SourceType, PP.MfgLotSize, OPR.OpCode
FROM erp.part P 
INNER JOIN PartPlant PP
ON PP.PartNum = P.PartNum
INNER JOIN erp.PartOpr OPR
ON P.PartNum = OPR.PartNum
where P.inactive = 0 
AND P.PartNum LIKE 'A-X0149'
AND PP.SourceType = 'M'
order by mfglotsize desc
--AND OPR.opcode LIKE 'A%-AEM'
)
COMMIT;

SELECT * FROM erp.SugPODtl WHERE Plant = 'GLENDN' order by OrderByDate
SELECT * From erp.partdtl


SELECT Plant,part.PartNum,LeadTime 
FROM erp.partplant
INNER JOIN erp.part
ON part.partnum = partplant.partnum
where part.inactive = 0

SELECT VendorID,CalendarID From erp.Vendor
SELECT ResourceGrpID,CalendarID FROM erp.ResourceGroup
BEGIN TRANSACTION;
UPDATE erp.ResourceGroup
SET CalendarID = 'AU6101'
COMMIT