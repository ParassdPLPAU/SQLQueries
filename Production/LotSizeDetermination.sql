SELECT JO.JobComplete,JO.OpComplete,JO.QtyCompleted,JO.JobNum,Jo.AssemblySeq,JO.OprSeq,JO.OpCode,JO.EstSetHours,JO.EstProdHours,JO.ActSetupHours,JO.ActProdHours,
JO.ProdStandard,JO.StdFormat,JO.QtyPer,JO.StartDate,JO.DueDate
FROM erp.JobOper JO
inner join erp.JobAsmbl JA on JO.JobNum = JA.JobNum AND JO.AssemblySeq = JA.AssemblySeq
where JA.JobComplete = 1 and JA.partnum = 'CTA-315-02012' and JA.StartDate > '2024-01-01';
--SELECT * FROM erp.PartOpr;
--SELECT *
--FROM 
--		erp.PartOpr PO
--	INNER JOIN  erp.PartPlant PP
--	ON PO.PartNum = PP.PartNum 
--	INNER JOIN erp.Part ON Part.PartNum = PP.PartNum
--	WHERE Plant = 'GLENDN'


WITH PartData AS (
	SELECT 
		PO.PartNum,
		Part.PartDescription,
		Part.ProdCode,
		RevisionNum,
		OprSeq,
		OpCode,
		OpDesc,
		EstSetHours,
		EstProdHours,
		ProdStandard,
		StdFormat,
		QtyPer,
		RunQty,
		SetUpCrewSize,
		ProdCrewSize,
		SubContract,
		DaysOut,
		PO.CommentText AS 'PartOpComment',
		Part.CommentText AS 'PartComment'
	FROM 
		erp.PartOpr PO
	INNER JOIN  erp.PartPlant PP
	ON PO.PartNum = PP.PartNum 
	INNER JOIN erp.Part ON Part.PartNum = PP.PartNum
	WHERE Plant = 'GLENDN'
)--SELECT * FROM PartData
, JobData AS (
	SELECT 
		JO.JobComplete,
		OpComplete,
		JO.JobNum,
		JA.PartNum,
		JO.AssemblySeq,
		OprSeq,
		OpCode,
		OPDesc,
		EstSetHours,
		EstProdHours,
		ProdStandard,
		StdFormat,
		JA.RequiredQty AS 'PlannedProdQty',
		JO.QtyPer AS 'OpQtyPer',
		JA.QtyPer AS 'AssmblyQtyPer',
		SetUpCrewSize,
		ProdCrewSize,
		ProdComplete,
		SetupComplete,
		ActProdHours,
		ActSetupHours,
		QtyCompleted,
		SubContract,
		DaysOut,
		JO.CommentText AS 'OpComment',
		JA.CommentText AS 'AssmblyComment',
		RunQty
	FROM
		erp.JobOper JO
	INNER JOIN 
		erp.JobAsmbl JA
	ON JA.AssemblySeq = JO.AssemblySeq AND JA.JobNum = JO.JobNum
	WHERE JA.JobComplete = 1 
	AND JA.StartDate > '01-01-2024'
	--AND JA.PartNum = 'A-X0991'
),PartJobHrs AS (
	SELECT 
		PartNum,
		OpCode,
		OpDesc,
		OprSeq,
		AVG(PlannedProdQty) AS 'AvgAssmblyPlannedQty',
		AVG(AssmblyQtyPer) AS 'AvgAssmblyQtyPer',
		AVG(OpQtyPer) as 'AvgOpQtyPer',
		AVG(QtyCompleted) AS 'AvgOpQtyCompleted',
		AVG(RunQty) AS 'AvgRunQty',
		AVG(ActSetupHours) AS 'JobAvgActSetupHrs',
		AVG(ActProdHours) AS 'JobAvgActProdHrs',
		MAX(ProdStandard) AS 'JobMaxProdStandard',
		StdFormat AS 'JobStdFormat'
	FROM JobData
	GROUP BY PartNum, OpCode,OpDesc, OprSeq, StdFormat
)
SELECT 
	PartJobHrs.*,
	CASE 
		WHEN JobAvgActProdHrs = 0 THEN 0 ELSE	
		PartJobhrs.JobAvgActSetupHrs/PartJobhrs.JobAvgActProdHrs END AS '%SetupofProdHours',
	EstSetHours AS 'MoMEstSetHrs',
	EstProdHours AS 'MoMEstProdHrs',
	PartData.ProdStandard AS 'MoMProdStandard',
	PartData.StdFormat AS 'MoMStdFormat',
	CASE WHEN (EstSetHours + EstProdHours) = 0 THEN 0
	ELSE EstSetHours / (EstSetHours + EstProdHours)
	END AS 'Setup %',
	SubContract
FROM PartJobHrs
INNER JOIN PartData ON PartData.PartNum = PartJobHrs.PartNum 
AND PartData.OpCode = PartJobHrs.OpCode
AND PartData.OprSeq = PartJobHrs.OprSeq
ORDER BY PartNum ASC, OprSeq ASC