--Job details

--CODE TO CHECK DATA
SELECT * FROM JobHead

--Jobs firmed
WITH BASE AS (SELECT JobNum,PartNum,RevisionNum,JobFirm,JobEngineered,JobReleased,JobHeld,SchedStatus,JobComplete,JobClosed,SchedLocked,OrigProdQty,QtyCompleted,IUM,CreateDate,StartDate,DueDate,
	ReqDueDate,JobCompletionDate,ClosedDate,WIStartDate,WIDueDate,TravelerLastPrinted,PlannedActionDate,PlannedKitDate,DaysLate,SchedSeq
FROM JobHead WHERE CreateDate >= '2024-01-01'
)
--SELECT * FROM BASE ORDER BY CreateDate DESC
--,BASE_2 AS (
--	SELECT COUNT(*) AS 'Count1' FROM BASE WHERE JobFirm = 1 AND JobEngineered = 0
--), BASE_3 AS (
--	SELECT COUNT(*) AS 'Count2' FROM BASE WHERE JobReleased = 1 AND JobFirm = 0
--)
--SELECT * FROM BASE_2 FULL OUTER JOIN BASE_3 ON BASE_2.Count1 = BASE_3.Count2;
--SELECT COUNT(*) AS 'Firm1Engineered0' FROM BASE WHERE JobFirm = 1 AND JobEngineered = 0;
SELECT COUNT(*) FROM BASE WHERE (JobReleased = 0 AND JobFirm = 1) OR (JobReleased = 1 AND JobFirm = 0);
SELECT COUNT(*) FROM JobHead WHERE CreateDate >= '2024-01-01'

SELECT JobNum,PartNum,RevisionNum,JobFirm,JobEngineered,JobReleased,JobHeld,SchedStatus,JobComplete,JobClosed,SchedLocked,OrigProdQty,QtyCompleted,IUM,CreateDate,StartDate,DueDate,
	ReqDueDate,JobCompletionDate,ClosedDate,WIStartDate,WIDueDate,TravelerLastPrinted,PlannedActionDate,PlannedKitDate,DaysLate,SchedSeq
FROM JobHead WHERE JobNum = 'J077841'

SELECT Plant,Part.PartNum,MfgLotSize FROM PartPlant INNER JOIN Part ON part.partnum = partPlant.partnum WHERE Inactive = 0 --and plant = 'GLNDN'