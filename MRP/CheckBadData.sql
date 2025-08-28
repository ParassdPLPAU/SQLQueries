--Check bad records on JA wrt JH
SELECT * FROM erp.JobAsmbl JA
LEFT JOIN erp.JobHead JH ON JH.JobNum = JA.JobNum
WHERE JH.JobNum IS NULL order by JH.jobnum asc

--Check past jobs as per planner
SELECT JH.JobNum,JA.PartNum,JH.PersonID,JA.JobComplete,JA.StartDate,JA.DueDate,JH.ProdQty FROM erp.JobAsmbl JA
LEFT JOIN erp.JobHead JH ON JA.JobNum = JH.JobNum
WHERE JA.DueDate < '2025-07-01' and JH.JobClosed <> 1 AND JobNum
order by duedate asc

--Responsible planner
SELECT JH.PersonID,COUNT(*) AS 'TotalRecords' FROM erp.JobAsmbl JA
LEFT JOIN erp.JobHead JH ON JA.JobNum = JH.JobNum
WHERE JA.DueDate < '2025-07-01' and JH.JobClosed <> 1 
GROUP BY JH.PersonID

--Jobs with due dates in the past not closed
SELECT * FROM erp.JobHead
WHERE JobClosed = 0 and DueDate <= '2025-07-01'

--Job headers that don't have any Assembly records
SELECT * FROM erp.JobHead JH
LEFT JOIN erp.JobAsmbl JA ON JH.JobNum = JA.JobNum
WHERE JA.JobNum IS NULL

--Job Assembly records without any operations
SELECT * FROM erp.JobAsmbl JA
LEFT JOIN erp.JobOper JO on JO.JobNum = JA.JobNum
WHERE JO.JobNum IS NULL and JA.JobComplete = 0 AND JA.Jobnum NOT LIKE '%U%'
order by JA.jobnum asc

--Job operations that don't have any assembly records
SELECT * FROM erp.JobOper JO
LEFT JOIN erp.JobAsmbl JA on JO.JobNum = JA.JobNum
WHERE JA.JobNum IS NULL

--Job Assembly records that don't have any materials assigned to be issued
SELECT * FROM erp.JobAsmbl JA 
LEFT JOIN erp.JobMtl JM ON JM.JobNum = JA.JobNum
WHERE JM.JobNum IS NULL and JA.JobComplete = 0 AND JA.Jobnum NOT LIKE '%U%'

--Job Material records that aren't tied to any assemblies
SELECT * FROM erp.JobMtl JM
LEFT JOIN erp.JobAsmbl JA ON JM.JobNum = JA.JobNum
WHERE JA.JobNum IS NULL

--Bad data in PartPlant
SELECT * FROM erp.PartPlant PP
LEFT JOIN erp.Part P ON PP.Partnum = P.Partnum
WHERE PP.PartNum IS NULL

--Bad data in Part
SELECT * FROM erp.Part P
LEFT JOIN erp.PartPlant PP ON PP.Partnum = P.Partnum
WHERE PP.PartNum IS NULL

--Bad data in PartDtl
SELECT * FROM erp.PartDtl PD
LEFT JOIN erp.Part P ON P.PartNum = PD.PartNum
WHERE PD.PartNum IS NULL


SELECT * FROM erp.PartDtl PD
LEFT JOIN erp.Jobhead JH ON JH.JobNum = PD.JobNum
WHERE pd.jobnum <> ''

SELECT * FROM erp.PartDtl PD
WHERE JobNum NOT IN (
SELECT JobNum FROM erp.Jobhead
) AND pd.jobnum <> ''

SELECT * FROM erp.PartDtl where jobnum = '026401'
SELECT * FROM erp.JobHead where JobNum = '026401'

SELECT * FROM erp.PartPlant PP
INNER JOIN erp.Part P ON P.PartNum = PP.PartNum AND PP.Plant = 'GLENDN'
LEFT JOIN erp.PartDtl PD ON PD.PartNum = PP.PartNum 
where inactive = 0 and constrained = 0
--AND SourceType = 'P' 
--AND SafetyQty <> 0
--AND LeadTime <= 14 AND SourceType = 'P'
AND PP.TotMfgLeadTimeSys <= 14 and SourceType = 'M'

--Check materials issued a month in advance
SELECT 
JH.JobClosed, JH.JobComplete, JH.JobNum, JH.StartDate, JH.DueDate, JH.ReqDueDate,
JH.PartNum, JM.PartNum AS 'MtlPartNum', JM.ReqDate AS 'MtlReqDate',
JM.issuedqty,JM.IssuedComplete,  JH.CommentText, 
JH.SchedLocked, JH.PersonID, JH.TravelerLastPrinted
From ERP.JobHead JH
LEFT JOIN ERP.JobMtl JM ON JM.JobNum = JH.JobNum
where --JH.JobClosed = 0 and
 JM.issuedqty <> 0
and StartDate >= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
order by StartDate desc