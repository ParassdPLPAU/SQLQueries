--Issues with the query, cannot identify parts that are in the partmtl table but not on the job.
--First get all the relevent BoM data from the jobs
WITH JobData AS (
	--First half of the query will not pick up any subassemblies - only looks at materials on a subassembly
	--NULL values if only subassembly without any materials
	SELECT 
		JA.JobNum,
		JA.AssemblySeq,
		JA.Parent,
		JA.PriorPeer,
		JA.NextPeer,
		JA.Child,
		JA.PartNum AS 'AssemblyPartNum',
		JA.RevisionNum AS 'JobRevNum',
		JA.QtyPer AS 'JobAssemblyQtyPerParent',
		JM.MtlSeq AS 'JobMtlSeq',
		JM.PartNum AS 'JobMtlPartNum',
		JM.QtyPer AS 'JobMtlQtyPerParent'
	FROM erp.JobAsmbl JA
	LEFT JOIN erp.JobMtl JM ON JA.AssemblySeq = JM.AssemblySeq AND JA.JobNum = JM.JobNum
	WHERE JA.JobComplete = 0
	UNION ALL -- Join all subassemblies with parent child relationship that will not get picked up by previous query
	-- Need to be able to identify parent child relationship between subassemblies
	--NULL values if no subassemblies
	SELECT 
		JA1.JobNum,
		JA1.AssemblySeq,
		CASE WHEN
		JA1.AssemblySeq = JA1.Parent THEN -1
		ELSE JA1.Parent 
		END AS 'Parent',
		JA1.PriorPeer,
		JA1.NextPeer,
		JA1.Child,
		JA1.PartNum AS 'AssemblyPartNum',
		JA1.RevisionNum AS 'JobRevNum',
		JA1.QtyPer AS 'JobAssemblyQtyPerParent',
		JA2.AssemblySeq AS 'JobMtlSeq',
		JA2.PartNum AS 'JobMtlPartNum',
		JA2.QtyPer AS 'JobMtlQtyPerParent'
	FROM erp.JobAsmbl JA1
	LEFT JOIN
		erp.JobAsmbl JA2 ON JA1.AssemblySeq = JA2.Parent 
		AND JA1.JobNum = JA2.JobNum 
		AND JA1.PartNum <> JA2.PartNum --Remove chance of parent joining back to itself since parent -1 
	WHERE JA1.JobComplete = 0
), PartData AS (
--Get all BoM data as per method tracker
	SELECT 
		PM.PartNum,
		PM.RevisionNum AS 'PartRevNum',
		MtlSeq AS 'PartMtlSeq',
		MtlPartNum AS 'PartMtlPartNum',
		QtyPer AS 'PartChildQtyPer',
		PullAsAsm
	FROM erp.PartMtl PM
	INNER JOIN erp.PartRev PR ON PM.PartNum = PR.PartNum AND PM.RevisionNum = PR.RevisionNum
	WHERE Approved = 1 --Only approved revisions
), BASE AS (
	SELECT 
		--Identify all null values from the UNION in JobData CTE
		--for each row do a case to identify whether it's a NULL row or a NON NULL row
		--Assign 0 to NULL and 1 to non-null
		CASE WHEN JobMtlSeq IS NOT NULL THEN 1 ELSE 0 END AS NullFlag,
		--Window function to tag rows which ONLY have a NULL dataset
		--After this filter for max in that window
		--So if the window only has NULLs max would be 0
		MAX(CASE WHEN JobMtlSeq IS NOT NULL THEN 1 ELSE 0 END) OVER (
			PARTITION BY JD.JobNum, JD.AssemblySeq
		) AS 'MaxNonNull',
		*,
		CASE 
			WHEN PD.PartMtlPartNum IS NULL THEN 'Missing part in PartMtl'
			WHEN JD.JobMtlPartNum IS NULL THEN 'Missing part in JobMtl'
			WHEN PD.PartMtlPartNum <> PD.PartMtlPartNum THEN 'Part Mismatch'
			WHEN PD.PartChildQtyPer <> JD.JobMtlQtyPerParent THEN 'Qty mismatch'
			WHEN JD.JobMtlSeq <> PD.PartMtlSeq THEN 'Mtl Seq mismatch'
			ELSE 'Match'
		END AS Difference_Check
	FROM JobData JD
	FULL OUTER JOIN PartData PD
	ON JD.AssemblyPartNum = PD.PartNum
	AND JD.JobMtlPartNum = PD.PartMtlPartNum
	)
SELECT DISTINCT *
FROM BASE Where NOT (MaxNonNull = 1 AND NullFlag = 0) AND Difference_Check <> 'Match' AND Difference_Check <> 'Mtl Seq mismatch'
ORDER BY JobNum,AssemblySeq,JobMtlSeq,PartNum,PartMtlSeq