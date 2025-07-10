--WITH Anchor AS (
--    SELECT
--        JP.JobNum,
--        JH.StartDate,
--        JH.JobReleased,
--        JH.DueDate,
--        JH.ReqDueDate,
--        JP.PartNum,
--        JH.PartDescription,
--		JH.RevisionNum,
--        JP.ProdQty,
--        JH.JobCompletionDate,
--        JP.OrderNum,
--        JP.OrderLine,
--        JP.OrderRelNum,
--        JP.TargetJobNum,
--        JP.TargetAssemblySeq,
--        JP.TargetMtlSeq,
--        0 AS lvl,
--        JH.JobFirm
--    FROM Erp.JobProd JP
--    INNER JOIN Erp.JobHead JH ON JP.Company = JH.Company AND JP.JobNum = JH.JobNum
--	INNER JOIN erp.PartPlant PP ON PP.PartNum = JP.PartNum
--	INNER JOIN erp.OrderRel ORL ON ORL.OrderNum = JP.OrderNum
--		AND ORL.OrderLine = JP.OrderLine
--		AND ORL.OrderRelNum = JP.OrderRelNum
--	WHERE JP.OrderNum <> 0 AND PP.PersonID LIKE '%AEM%' and ORL.OpenRelease = 1

--    UNION ALL

--    SELECT
--        JP1.JobNum,
--        JH1.StartDate,
--        JH1.JobReleased,
--        JH1.DueDate,
--        JH1.ReqDueDate,
--        JP1.PartNum,
--        JH1.PartDescription,
--		JH1.RevisionNum,
--        JP1.ProdQty,
--        JH1.JobCompletionDate,
--        A.OrderNum,
--        A.OrderLine,
--        A.OrderRelNum,
--        JP1.TargetJobNum,
--        JP1.TargetAssemblySeq,
--        JP1.TargetMtlSeq,
--        A.lvl + 1,
--        JH1.JobFirm
--    FROM Anchor A
--    INNER JOIN Erp.JobProd JP1 ON A.JobNum = JP1.TargetJobNum
--    INNER JOIN Erp.JobHead JH1 ON JP1.Company = JH1.Company AND JP1.JobNum = JH1.JobNum
--)

--SELECT
--    A.lvl,
--    A.JobNum,
--    A.StartDate,
--    A.JobReleased,
--    A.DueDate,
--    A.ReqDueDate,
--    A.JobCompletionDate,
--    A.PartNum,
--    A.RevisionNum,
--    A.PartDescription,
--    A.OrderNum,
--    A.OrderLine,
--    A.OrderRelNum,
--    A.ProdQty,
--    A.TargetJobNum,
--    A.TargetAssemblySeq,
--    A.TargetMtlSeq,
--    JH2.JobNum AS JobHead2_JobNum,
--    JH2.PartNum AS JobHead2_PartNum,
--    JH2.RevisionNum AS JobHead2_RevisionNum,
--    JH2.JobCode AS JobHead2_JobCode,
--    JH2.JobFirm AS JobHead2_JobFirm
--FROM Anchor A
--INNER JOIN Erp.JobHead JH2 ON A.JobNum = JH2.JobNum
--ORDER BY A.OrderNum, A.OrderLine, A.OrderRelNum, A.lvl, A.StartDate;




--SQL recreation of flattened bom hierarchy
WITH Anchor AS (
    SELECT
		CASE 
			WHEN PATINDEX('%kV%', P.PartDescription) > 0 THEN
				LTRIM(RTRIM(
					SUBSTRING(
						P.PartDescription,
						-- Start: go back to the space before the kV word
						LEN(LEFT(P.PartDescription, PATINDEX('%kV%', P.PartDescription) - 1)) 
							- CHARINDEX(' ', REVERSE(LEFT(P.PartDescription, PATINDEX('%kV%', P.PartDescription) - 1))) + 2,
						-- Length: from that space up to the next space
						CHARINDEX(' ', P.PartDescription + ' ', PATINDEX('%kV%', P.PartDescription)) 
							- (
								LEN(LEFT(P.PartDescription, PATINDEX('%kV%', P.PartDescription) - 1)) 
								- CHARINDEX(' ', REVERSE(LEFT(P.PartDescription, PATINDEX('%kV%', P.PartDescription) - 1))) + 2
							  )
					)
				))
			ELSE NULL
		END AS KV_Word_long,
        JP.JobNum AS Job_L0,
		JP.JobNum AS Job_L1,
        JP.JobNum AS Job_L2,
		JP.JobNum AS Job_L3,
		JP.JobNum AS Job_L4,
		JP.JobNum AS LeafJob,
		JP.PartNum AS Part_L0,
		JP.PartNum AS Part_L1,
        JP.PartNum AS Part_L2,
		JP.PartNum AS Part_L3,
		JP.PartNum AS Part_L4,
		JH.StartDate,
        JH.JobReleased,
        JH.DueDate,
        JH.ReqDueDate,
        JP.PartNum,
        JH.PartDescription,
		JH.RevisionNum,
        JP.ProdQty,
        JH.JobCompletionDate,
        JP.OrderNum,
        JP.OrderLine,
        JP.OrderRelNum,
		JP.PartNum AS 'SOPartNum',
        JP.TargetJobNum,
        JP.TargetAssemblySeq,
        JP.TargetMtlSeq,
        0 AS lvl,
        JH.JobFirm
    FROM Erp.JobProd JP
    INNER JOIN Erp.JobHead JH ON JP.Company = JH.Company AND JP.JobNum = JH.JobNum
	INNER JOIN erp.PartPlant PP ON PP.PartNum = JP.PartNum
	INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
	INNER JOIN erp.OrderRel ORL ON ORL.OrderNum = JP.OrderNum
		AND ORL.OrderLine = JP.OrderLine
		AND ORL.OrderRelNum = JP.OrderRelNum
	WHERE JP.OrderNum <> 0 AND PP.PersonID LIKE '%AEM%' and ORL.OpenRelease = 1 AND PP.Plant = 'GLENDN'

    UNION ALL

    SELECT
		A.KV_Word_long,
        A.Job_L0,
		CASE 
			WHEN A.lvl = 0 THEN JP1.JobNum
			WHEN A.lvl > 0 THEN A.Job_L1
		END AS Job_L1,
		CASE 
			WHEN A.lvl < 1  THEN JP1.JobNum
			WHEN A.lvl = 1 THEN JP1.JobNum
			WHEN A.lvl > 1 THEN A.Job_L2
		END AS Job_L2,
		CASE 
			WHEN A.lvl < 2 THEN JP1.JobNum
			WHEN A.lvl = 2 THEN JP1.JobNum
			WHEN A.lvl > 2 THEN A.Job_L3
		END AS Job_L3,
		CASE 
			WHEN A.lvl < 3 THEN JP1.JobNum
			WHEN A.lvl = 3 THEN JP1.JobNum
			WHEN A.lvl > 3 THEN A.Job_L4
		END AS Job_L4,
		JP1.JobNum AS 'LeafJob',
		A.Part_L0,
		CASE 
			WHEN A.lvl = 0 THEN JP1.PartNum
			WHEN A.lvl > 0 THEN A.Part_L1
		END AS Part_L1,
		CASE 
			WHEN A.lvl < 1  THEN JP1.PartNum
			WHEN A.lvl = 1 THEN JP1.PartNum
			WHEN A.lvl > 1 THEN A.Part_L2
		END AS Part_L2,
		CASE 
			WHEN A.lvl < 2 THEN JP1.PartNum
			WHEN A.lvl = 2 THEN JP1.PartNum
			WHEN A.lvl > 2 THEN A.Part_L3
		END AS Part_L3,
		CASE 
			WHEN A.lvl < 3 THEN JP1.PartNum
			WHEN A.lvl = 3 THEN JP1.PartNum
			WHEN A.lvl > 3 THEN A.Part_L4
		END AS Part_L4,
        JH1.StartDate,
        JH1.JobReleased,
        JH1.DueDate,
        JH1.ReqDueDate,
        JP1.PartNum,
        JH1.PartDescription,
		JH1.RevisionNum,
        JP1.ProdQty,
        JH1.JobCompletionDate,
        A.OrderNum,
        A.OrderLine,
        A.OrderRelNum,
		A.SOPartNum,
        JP1.TargetJobNum,
        JP1.TargetAssemblySeq,
        JP1.TargetMtlSeq,
        A.lvl + 1,
        JH1.JobFirm
    FROM Anchor A
    INNER JOIN Erp.JobProd JP1 ON A.LeafJob = JP1.TargetJobNum
    INNER JOIN Erp.JobHead JH1 ON JP1.Company = JH1.Company AND JP1.JobNum = JH1.JobNum
)

SELECT
    A.lvl,
	C.CustID,
	A.KV_Word_long,
    A.Job_L0,
	A.Job_L1,
	A.Job_L2,
	A.Job_L3,
	A.Job_L4,
	A.LeafJob,
    A.StartDate,
    A.JobReleased,
    A.DueDate,
    A.ReqDueDate,
    A.JobCompletionDate,
    A.PartNum,
    A.RevisionNum,
    A.PartDescription,
    A.OrderNum,
    A.OrderLine,
    A.OrderRelNum,
	CASE WHEN A.lvl = 0 THEN ORL.ReqDate ELSE NULL END AS 'ShipByDate',
	CASE WHEN A.lvl = 0 THEN OD.Promise_date_c ELSE NULL END AS 'PromiseDate',
	A.SOPartNum,
	A.Part_L0,
	A.Part_L1,
	A.Part_L2,
	A.Part_L3,
	A.Part_L4,
    A.ProdQty,
    A.TargetJobNum,
    A.TargetAssemblySeq,
    A.TargetMtlSeq,
    JH2.JobNum AS JobHead2_JobNum,
    JH2.PartNum AS JobHead2_PartNum,
    JH2.RevisionNum AS JobHead2_RevisionNum,
    JH2.JobCode AS JobHead2_JobCode,
    JH2.JobFirm AS JobHead2_JobFirm
FROM Anchor A
INNER JOIN Erp.JobHead JH2 ON A.Job_L1 = JH2.JobNum
INNER JOIN dbo.OrderDtl OD ON A.OrderNum = OD.OrderNum AND A.OrderLine = OD.OrderLine
INNER JOIN erp.OrderRel ORL ON A.OrderNum = ORL.OrderNum AND A.OrderLine = ORL.OrderLine AND A.OrderRelNum = ORL.OrderRelNum
INNER JOIN erp.Customer C ON C.CustNum = OD.CustNum
ORDER BY A.OrderNum, A.OrderLine, A.OrderRelNum, A.lvl, A.StartDate