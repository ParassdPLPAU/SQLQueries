SELECT DISTINCT (DemandType) FROM erp.PegDmdMst where DemandType = Demandseq = 2507 --This is demand for this part ie material in a job
SELECT * FROM erp.PegSupMst where supplyseq = 12082
--partnum = 'A-X0537' --This is supply to our warehouse ie job
SELECT * FROM erp.PegLink where demandseq = 2507

SELECT D.Plant,D.DemandSeq,D.DemandOrdNum,D.DemandOrdRel,D.PartNum AS 'DPart',D.DemandType,D.DemandDate,D.DemandQty,D.PeggedQty AS 'DmdQty',
L.PegNum,L.DemandSeq,L.SupplySeq,L.PeggedQty AS 'LinkQty', L.PartNum AS 'LPart',
S.SupplySeq,S.SupplyOrdNum, S.PartNum AS 'SPart',S.SupplyType,SupplyDate,SupplyQty,S.PeggedQty AS 'SupQty'
FROM erp.PegDmdMst D
LEFT JOIN erp.PegLink L
ON L.DemandSeq = D.DemandSeq
AND L.Plant = D.Plant 
AND L.PartNum = D.PartNum
AND L.Company = D.Company
LEFT JOIN erp.PegSupMst S
ON S.SupplySeq = L.SupplySeq
AND S.Plant = L.Plant
AND S.Company = L.Company
AND S.PartNum = L.PartNum
Select * from erp.partdtl where partnum = 'A-X0538'

--Testing the recursion flow for MPD
SELECT * FROM erp.PegDmdMst where partnum = 'A-X0999-01' --Pick 2354596 Order Line 2 Rel 1
--Identify the job supplying to the demand in the demand table for above SO picked with demandseq as 470
SELECT * FROM erp.PegLink where demandseq = 20
--Select the supplyordernum in the below table and use that in the call for the peg demand master
SELECT * FROM erp.PegSupMst where SupplySeq = 6955

SELECT * FROM erp.PegLink where supplyseq = 6955
--You will find the children demand sequences for the supplyordernum identified in the step above
--need to go down recursively this tree
SELECT * FROM erp.PegDmdMst where DemandOrdNum = 'J093772'

SELECT * FROM erp.PegLink where demandseq = 4721 --OR demandseq = 4722

SELECT * FROM erp.PegSupMst where SupplySeq = 6346 --OR SupplySeq = 6352

SELECT * FROM erp.PegDmdMst where DemandOrdNum = 'J092080' --OR DemandOrdNum = 'J092082'

SELECT * FROM erp.PegLink where demandseq = 864

SELECT * FROM erp.PegSupMst where SupplySeq = 2517 OR SupplySeq = 6371

SELECT * FROM erp.PegDmdMst where DemandOrdNum = 'J092185' --OR DemandOrdNum = 'J092082'

SELECT * FROM erp.PegLink where demandseq = 1014

SELECT * FROM erp.PegSupMst where SupplySeq = 6382

SELECT * FROM erp.PegDmdMst where DemandOrdNum = 'J092186'

SELECT * FROM erp.PegLink where demandseq = 1136

SELECT * FROM erp.PegSupMst where SupplySeq = 2516 OR SupplySeq = 11117

SELECT * FROM erp.PegDmdMst where DemandOrdNum = 'U0000000001944'

SELECT * FROM erp.PegLink where demandseq = 21020

SELECT * FROM erp.PegSupMst where SupplySeq = 2514

--Going down the tree
WITH BASE AS (
	SELECT D.Company,
		D.Plant,
		D.PartNum AS 'DmdPartNum',
		D.DemandOrdNum,
		D.DemandSeq,
		D.PeggedQty AS 'DmdPegQty',
		S.PartNum AS 'SupPartNum',
		S.SupplyOrdNum,--D.DemandOrdLine,D.DemandOrdRel,
		S.SupplySeq,
		S.SupplyType,
		L.PeggedQty AS 'SupPegQty',
		0 as lvl
	FROM erp.PegDmdMst D
	INNER JOIN erp.PegLink L 
		ON L.DemandSeq = D.DemandSeq
		AND L.Plant = D.Plant
		AND L.Company = D.Company
	INNER JOIN erp.PegSupMst S
		ON L.SupplySeq = S.SupplySeq
		AND L.Plant = S.Plant
		AND L.Company = S.Company
	WHERE D.PartNum = 'A-X0999-01'
	AND D.DemandOrdNum = 2360101
	AND D.DemandOrdLine = 20
	UNION ALL
	SELECT B.Company,
		B.Plant,
		B.SupPartNum,
		B.SupplyOrdNum,
		B.SupplySeq,
		B.SupPegQty,
		S1.PartNum,
		S1.SupplyOrdNum,--D.DemandOrdLine,D.DemandOrdRel,
		S1.SupplySeq,
		S1.SupplyType,
		L1.PeggedQty AS 'SupPegQty',
		B.lvl+1 as lvl
	FROM erp.PegDmdMst D1
	INNER JOIN BASE B
		ON B.SupplyOrdNum = D1.DemandOrdNum 
		--AND B.SupPartNum = D1.PartNum
		AND B.Plant = D1.Plant
	INNER JOIN erp.PegLink L1
		ON L1.DemandSeq = D1.DemandSeq
		AND L1.Plant = D1.Plant
		--AND L1.PartNum = D1.PartNum
		AND L1.Company = D1.Company
	INNER JOIN erp.PegSupMst S1
		ON L1.SupplySeq = S1.SupplySeq
		AND L1.Plant = S1.Plant
		AND S1.SupplyOrdNum <> ''
		--AND L1.Partnum = S1.PartNum
		AND L1.Company = S1.Company
)

SELECT * FROM BASE where suppartnum = 'RMFS-32X6-250'
--order by lvl;

--Going up the tree
WITH BASE AS (
	SELECT D.Company,
		D.Plant,
		D.PartNum AS 'DmdPartNum',
		D.DemandOrdNum,
		D.DemandSeq,
		D.PeggedQty AS 'DmdPegQty',
		S.PartNum AS 'SupPartNum',
		S.SupplyOrdNum,--D.DemandOrdLine,D.DemandOrdRel,
		S.SupplySeq,
		S.SupplyType,
		L.PeggedQty AS 'SupPegQty',
		0 as lvl
	FROM erp.PegDmdMst D
	INNER JOIN erp.PegLink L 
		ON L.DemandSeq = D.DemandSeq
		AND L.Plant = D.Plant
		AND L.Company = D.Company
	INNER JOIN erp.PegSupMst S
		ON L.SupplySeq = S.SupplySeq
		AND L.Plant = S.Plant
		AND L.Company = S.Company
	WHERE D.PartNum = 'A-X0999-01'
	AND D.DemandOrdNum = 2360101
	AND D.DemandOrdLine = 20
	UNION ALL
	SELECT B.Company,
		B.Plant,
		B.SupPartNum,
		B.SupplyOrdNum,
		B.SupplySeq,
		B.SupPegQty,
		S1.PartNum,
		S1.SupplyOrdNum,--D.DemandOrdLine,D.DemandOrdRel,
		S1.SupplySeq,
		S1.SupplyType,
		L1.PeggedQty AS 'SupPegQty',
		B.lvl+1 as lvl
	FROM erp.PegDmdMst D1
	INNER JOIN BASE B
		ON B.SupplyOrdNum = D1.DemandOrdNum 
		--AND B.SupPartNum = D1.PartNum
		AND B.Plant = D1.Plant
	INNER JOIN erp.PegLink L1
		ON L1.DemandSeq = D1.DemandSeq
		AND L1.Plant = D1.Plant
		--AND L1.PartNum = D1.PartNum
		AND L1.Company = D1.Company
	INNER JOIN erp.PegSupMst S1
		ON L1.SupplySeq = S1.SupplySeq
		AND L1.Plant = S1.Plant
		AND S1.SupplyOrdNum <> ''
		--AND L1.Partnum = S1.PartNum
		AND L1.Company = S1.Company
)

SELECT * FROM BASE order by lvl;

--Going down the three
SELECT * FROM erp.PegDmdMst where PartNum = 'A-X0346-05'

WITH BASE_2 AS (
	SELECT D.Company,
		D.Plant,
		D.PartNum AS 'DmdPartNum',
		D.DemandOrdNum,
		D.DemandSeq,
		D.PeggedQty AS 'DmdPegQty',
		S.PartNum AS 'SupPartNum',
		S.SupplyOrdNum,--D.DemandOrdLine,D.DemandOrdRel,
		S.SupplySeq,
		S.SupplyType,
		L.PeggedQty AS 'SupPegQty',
		0 as lvl
	FROM erp.PegDmdMst D
	INNER JOIN erp.PegLink L 
		ON L.DemandSeq = D.DemandSeq
		AND L.Plant = D.Plant
		AND L.Company = D.Company
	INNER JOIN erp.PegSupMst S
		ON L.SupplySeq = S.SupplySeq
		AND L.Plant = S.Plant
		AND L.Company = S.Company
	WHERE D.PartNum = 'A-X0999-01'
	AND D.DemandOrdNum = 2360101
	AND D.DemandOrdLine = 20
)