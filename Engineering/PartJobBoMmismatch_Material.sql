SELECT * from erp.PartOpr
SELECT * FROM erp.JobAsmbl where JobNum = 'J088270'
SELECT * FROM erp.JobMtl WHERE JobNum = 'U0000000001391'
SELECT * FROM erp.JobOper
SELECT * from erp.partmtl where partnum = 'A-A4350-02'
--SELECT * FROM erp.JobMtl WHERE JobNum = 'J081491'
SELECT * FROM erp.JobMtl JM INNER JOIN erp.JobHead JH
ON JH.JobNum = JM.JobNum WHERE JM.JobNum = 'J081491'
SELECT * FROM erp.JobAsmbl WHERE JobComplete = 0

--Query that works
SELECT JA.JobNum, JA.AssemblySeq,JA.PartNum AS 'ParentPartNum',
JM.MtlSeq,JM.PartNum,JM.QtyPer,
PM.MtlSeq,PM.PartNum AS 'ParentPartNum',PM.MtlPartNum AS 'BoMMtlPartNum'
FROM erp.JobMtl JM
INNER JOIN erp.JobAsmbl JA
ON JA.JobNum = JM.JobNum
FULL OUTER JOIN erp.PartMtl PM
ON PM.PartNum = JA.PartNum
AND PM.MtlPartNum = JM.PartNum
--WHERE JA.JobClosed = 0
--where PM.PartNum = 'A-A4350-02'
WHERE JA.JobNum = 'J099230'
order by JA.JobNum,JA.AssemblySeq, jm.MtlSeq,pm.PartNum,pm.mtlseq asc

SELECT * FROM erp.JobAsmbl JA WHERE PartNum = 'CDE-165-1'
SELECT * FROM JobHead WHERE JobNum = 'J081491'

--Query with erroneous data
WITH BASE AS (
SELECT 
    COALESCE(jh.PartNum, pm.PartNum) AS ParentPartNum,  -- Ensures visibility of missing JobMtl rows
    jh.JobNum, 
    jm.AssemblySeq, 
    jm.MtlSeq AS JobMtlSeq, 
    jm.QtyPer AS JobMtl_QtyPer, 
    pm.MtlSeq AS PartMtlSeq, 
    pm.QtyPer AS PartMtl_QtyPer, 
    pm.RevisionNum AS PartRevNum, 
    jm.RevisionNum AS JobRevNum, 
    pm.MtlPartNum AS PartMtl_MtlPartNum, 
    jm.PartNum AS JobMtl_MtlPartNum, 
    CASE 
        WHEN pm.MtlPartNum IS NULL THEN 'Missing part in PartMtl'
        WHEN jm.PartNum IS NULL THEN 'Missing part in JobMtl'
        WHEN pm.MtlPartNum <> jm.PartNum THEN 'Mismatch'
		WHEN pm.mtlseq <> jm.mtlseq THEN 'Mtl Seq mismatch'
		WHEN pm.QtyPer <> jm.QtyPer THEN 'Qty mismatch'
        ELSE 'Match'
    END AS Difference_Check
FROM erp.PartMtl pm  -- Ensure PartMtl is always included
LEFT JOIN erp.JobHead jh 
    ON jh.PartNum = pm.PartNum  -- Get parent part from JobHead
    --AND jh.JobNum = 'J081491'  -- Filter only on required JobNum
LEFT JOIN erp.JobMtl jm 
    ON jh.JobNum = jm.JobNum  -- Join JobMtl to JobHead
    AND pm.MtlPartNum = jm.PartNum  -- Match child part numbers
WHERE ReqDate >= '01-01-2024' and jh.JobClosed = 0
--WHERE COALESCE(jh.PartNum, pm.PartNum) = 'A-A4350-02'  -- Ensure correct filtering
--ORDER BY JobNum,JobMtlSeq, PartMtlSeq;
)
SELECT * FROM BASE where difference_check <> 'Match' AND JobNum IS NOT NULL ORDER BY JobNum,JobMtlSeq, PartMtlSeq;

--Fixed query
WITH BASE AS (
SELECT 
    COALESCE(jh.PartNum, pm.PartNum) AS ParentPartNum,  -- Ensures visibility of missing JobMtl rows
    jh.JobNum, 
    jm.AssemblySeq AS 'JobAssemblySeq', 
    jm.MtlSeq AS 'JobMtlSeq', 
    jm.QtyPer AS 'JobMtl_QtyPer', 
    pm.MtlSeq AS 'PartMtlSeq', 
    pm.QtyPer AS 'PartMtl_QtyPer', 
    pm.RevisionNum AS 'PartRevNum', 
    jm.RevisionNum AS 'JobRevNum', 
    pm.MtlPartNum AS 'PartMtl_MtlPartNum', 
    jm.PartNum AS 'JobMtl_MtlPartNum', 
    CASE 
        WHEN pm.MtlPartNum IS NULL THEN 'Missing part in PartMtl'
        WHEN jm.PartNum IS NULL THEN 'Missing part in JobMtl'
        WHEN pm.MtlPartNum <> jm.PartNum THEN 'Mismatch'
		WHEN pm.QtyPer <> jm.QtyPer THEN 'Qty mismatch'
		WHEN pm.mtlseq <> jm.mtlseq THEN 'Mtl Seq mismatch'
        ELSE 'Match'
    END AS Difference_Check
FROM erp.JobMtl jm  -- Ensure PartMtl is always included
INNER JOIN erp.JobHead jh 
    ON jh.JobNum = JM.JobNum  -- Get parent part from JobHead
    --AND jh.JobNum = 'J081491'  -- Filter only on required JobNum
FULL OUTER JOIN erp.PartMtl pm 
    ON pm.PartNum = jh.PartNum  -- Join JobMtl to JobHead
    AND pm.MtlPartNum = jm.PartNum  -- Match child part numbers
WHERE ReqDate >= '01-01-2024' and jh.JobClosed = 0
--WHERE COALESCE(jh.PartNum, pm.PartNum) = 'A-A4350-02'  -- Ensure correct filtering
--ORDER BY JobNum,JobMtlSeq, PartMtlSeq;
)
SELECT * FROM BASE where difference_check <> 'Match' and difference_check <> 'Mtl Seq mismatch'
--AND JobNum IS NOT NULL
ORDER BY JobNum,JobMtlSeq, PartMtlSeq;

SELECT TOP(100) * FROM erp.JobMtl order by JobMtl.ReqDate desc
--SELECT TOP(100) * FROM erp.JobAsmbl order by JobAsmbl.DueDate desc

SELECT * 
FROM erp.JobAsmbl JA
WHERE JA.JobNum IN (
    SELECT JobNum
    FROM erp.JobAsmbl
    GROUP BY JobNum
    HAVING COUNT(DISTINCT CASE WHEN AssemblySeq > 0 THEN 1 END) > 0
)
ORDER BY JA. JobNum DESC, JA. AssemblySeq, JA.DueDate DESC;

SELECT TOP(100) * FROM erp.PartMtl 

