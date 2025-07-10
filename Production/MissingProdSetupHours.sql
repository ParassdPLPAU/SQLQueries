-- SQL report to pull all parts where the operations have 0 hours in setup or production and there have been more than 5 jobs in Epicor overall

--CODE TO CHECK DATA

--Estimated Setup hrs 0 for non assembly lines OR est prod hrs is 0
SELECT PartOpr.PartNum,PartOpr.RevisionNum,PartOpr.OprSeq,PartOpr.OpDesc,PartOpr.EstSetHours,PartOpr.EstProdHours FROM erp.PartOpr WHERE ((EstSetHours = 0 AND OpDesc NOT LIKE'%Assembly%') OR EstProdHours = 0)
SELECT * from erp.JobHead

--Total jobs by part since Jan '22
SELECT PartNum,COUNT(*) 'TotalCount' from erp.JobHead WHERE StartDate >= '2022-01-01' GROUP BY PartNum ORDER BY TotalCount Desc 

--RUN THIS CODE TO GET THE MISSING REPORT
-- Assembly does not require setup hours
-- Subcontractors don't need production hours
WITH BASE AS ( --Total Count of jobs and filter products with more than 5 jobs since beginning)
	SELECT PartNum, COUNT(*) AS 'TotalCount'
    FROM Erp.JobHead
    GROUP BY PartNum
    HAVING (COUNT(*) >= 5)
	), BASE_2 AS (
	SELECT PartNum, RevisionNum, OprSeq, OpDesc, EstSetHours, EstProdHours
    FROM Erp.PartOpr
    WHERE (
		(EstSetHours = 0 AND OpDesc NOT LIKE'%Assembly%') OR -- Assembly does not require setup hours
		(EstProdHours = 0)
	)
)
SELECT BASE_2.PartNum, BASE_2.OprSeq, BASE_2.OprSeq AS Expr1, BASE_2.OpDesc, BASE_2.EstSetHours, BASE_2.EstProdHours, BASE.TotalCount
FROM BASE INNER JOIN
BASE_2 ON BASE.PartNum = BASE_2.PartNum
WHERE OpDesc NOT LIKE 'S%' -- remove subcontract hours
ORDER BY BASE.TotalCount DESC;

--Remove all revision Qs
WITH base
     AS (SELECT partnum,
                Count(*) AS 'TotalCount'
         FROM   erp.jobhead
         GROUP  BY partnum
         HAVING ( Count(*) >= 5 )),
     base_2
     AS (SELECT partnum,
                revisionnum,
                oprseq,
                opdesc,
                estsethours,
                estprodhours
         FROM   erp.partopr
         WHERE  ( ( estsethours = 0
                    AND opdesc NOT LIKE'%Assembly%' )
                   OR ( estprodhours = 0 ) ))
SELECT base_2.partnum,
       base_2.revisionnum,
       base_2.oprseq,
       base_2.oprseq AS Expr1,
       base_2.opdesc,
       base_2.estsethours,
       base_2.estprodhours,
       base.totalcount
FROM   base
       INNER JOIN base_2
               ON base.partnum = base_2.partnum
WHERE  opdesc NOT LIKE 'S%' AND RevisionNum <> 'Q'
ORDER  BY base.totalcount DESC; 

--Check missing drawings in BoMs
SELECT * From PartRev;
WITH BASE AS (
SELECT JobHead.PartNum,COUNT(*) 'TotalCount' from erp.JobHead GROUP BY PartNum HAVING COUNT(*) >= 5 
)

SELECT PartRev.PartNum, PartRev.RevisionNum, PartRev.DrawNum, Base.TotalCount
FROM PartRev INNER JOIN BASE ON PartRev.PartNum = BASE.PartNum
WHERE DrawNum = '' AND RevisionNum <> 'Q'
ORDER BY TotalCount DESC

--Need to remove RackTech products from the above query but do not have a unique field in the part master or the part rev to be able to determine
--rack products. Using operations table for that.

--List of all racktech products
SELECT PartNum, OpDesc from erp.PartOpr WHERE OpCode = 'RP07' ORDER BY PartNum Asc 

WITH BASE_2 AS (
SELECT DISTINCT PartNum from erp.PartOpr WHERE (OpCode <> 'RP07') AND (OpCode <> 'RP04')
), BASE AS (
SELECT JobHead.PartNum,COUNT(*) 'TotalCount' from erp.JobHead GROUP BY PartNum HAVING COUNT(*) >= 5 
)

SELECT PartRev.PartNum, PartRev.RevisionNum, Base.TotalCount
FROM PartRev INNER JOIN BASE ON PartRev.PartNum = BASE.PartNum
INNER JOIN BASE_2 ON Base_2.PartNum = Base.PartNum
--WHERE PartRev.PartNum NOT IN (Base_2.PartNum)
ORDER BY TotalCount DESC

SELECT PartNum, OpDesc from erp.PartOpr WHERE OpCode = 'RP14' ORDER BY PartNum Asc 

SELECT * FROM Part WHERE InActive = 0

--Report to find out all items that are not on a project or contract but are marked as buy to order
SELECT OrderHed.OrderNum, OrderRel.SellingReqQty,OrderRelNum,PartNum,OrderType_c AS 'Project',OrderHed.EntryPerson,Order_Type3_c AS 'Contract' From OrderRel 
INNER JOIN OrderHed ON OrderRel.OrderNum = OrderHed.OrderNum
WHERE OrderRel.OpenRelease = 1 and OrderRel.BuyToOrder = 1 ORDER BY OrderRelNum--and (NOT (OrderType_c = 1 OR Order_Type3_c = 1))

--Get standard cost of all parts
Select PartNum, StdLaborCost+StdBurdenCost+StdMaterialCost+StdMtlBurCost+StdSubContCost AS 'Std Total Cost' FROM erp.PartCost

--BoMs with one to one relationship
Select PartMtl.PartNum,PartMtl.MtlSeq,PartMtl.MtlPartNum,PartMtl.RelatedOperation,PartMtl.QtyPer,PartMtl.PullAsAsm FROM erp.PartMtl;

WITH BASE AS (
	Select PartMtl.MtlPartNum,COUNT(PartMtl.PartNum) AS 'Total Parents' 
	FROM erp.PartMtl  
	--INNER JOIN erp.Part
	--ON Part.PartNum = erp.PartMtl.MtlPartNum
	--WHERE erp.Part.TypeCode = 'M'
	GROUP BY PartMtl.MtlPartNum HAVING COUNT(PartMtl.PartNum) = 1
),BASE_2 AS (
SELECT JobHead.PartNum,COUNT(*) 'TotalCount' from erp.JobHead GROUP BY PartNum HAVING COUNT(*) >= 5 
)

SELECT PartMtl.MtlSeq,PartMtl.MtlPartNum,PartMtl.PartNum,PartMtl.RelatedOperation,PartMtl.QtyPer,PartMtl.PullAsAsm, TotalCount 
FROM erp.PartMtl INNER JOIN
BASE ON 
PartMtl.MtlPartNum = BASE.MtlPartNum INNER JOIN
BASE_2 ON
erp.PartMtl.PartNum = BASE_2.PartNum
ORDER BY TotalCount DESC




SELECT * FROM erp.PartMtl