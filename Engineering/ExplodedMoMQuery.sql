--WITH OpHours AS (
--SELECT 
--    PO.PartNum,
--	PO.RevisionNum,
--    SUM(PO.EstSetHours) AS TotalSetupHours,
--    SUM(PO.EstProdHours) AS TotalProdHours,
--	SUM(PO.ProdStandard) AS TotalProdStandard,
--	PO.StdFormat
--FROM erp.PartOpr PO 
--INNER JOIN Part ON Part.PartNum = PO.PartNum
--INNER JOIN PartRev ON Part.PartNum = PartRev.PartNum AND PartRev.RevisionNum = PO.RevisionNum
--WHERE Inactive = 0 AND PartRev.Approved = 1 
--GROUP BY PO.PartNum, PO.RevisionNum, PO.StdFormat
--), MoMExplosion AS (
--	SELECT 
--		PM.PartNum AS 'Parent',
--		PM.RevisionNum AS 'ParentRevNum',
--		PM.MtlSeq,
--		PM.MtlPartNum AS 'Child', 
--		PP.SourceType AS 'ChildType',
--		PM.QtyPer,
--		0 AS 'lvl' ,
--		P.InActive,
--		PP.PlanTimeFence,
--		CASE WHEN
--			PP.SourceType = 'P'
--			THEN PP.LeadTime
--			ELSE
--			PP.TotMfgLeadTimeSys
--		END AS 'LeadTime',
--		OH1.TotalSetupHours AS 'ChildTLSetHrs',
--		OH1.TotalProdHours AS 'ChildTLProdHrs',
--		OH1.TotalProdStandard AS 'ChildProdStandard',
--		OH1.StdFormat,
--		CAST(PM.PartNum + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
--		FROM erp.partmtl PM
--		INNER JOIN erp.PartPlant PP	ON PM.MtlPartNum = PP.PartNum 
--		INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
--		INNER JOIN erp.PartWhse PW ON P.PartNum = PW.PartNum
--		INNER JOIN erp.PartRev PR1 ON PR1.PartNum = PM.PartNum AND PM.RevisionNum = PR1.RevisionNum 
--		INNER JOIN OpHours OH1 ON OH1.PartNum = P.PartNum
--		INNER JOIN OpHours OH2 ON OH2.PartNum = PM.PartNum
--		WHERE PM.PartNum = 'A-A10066-08'
--		AND PP.Plant = 'GLENDN'
--		AND PW.WarehouseCode = '190'
--		AND PR1.Approved = 1
--		--AND PR2.Approved = 1
--	UNION ALL
--	SELECT 
--		CTE.Child AS 'Parent',
--		PM.RevisionNum AS 'ParentRevNum',
--		PM.MtlSeq,
--		PM.MtlPartNum AS 'Child', 
--		PP.SourceType AS 'ChildType',
--		PM.QtyPer,
--		CTE.lvl+1 AS 'lvl' ,
--		P.InActive,
--		PP.PlanTimeFence,
--		CASE WHEN
--			PP.SourceType = 'P'
--			THEN PP.LeadTime
--			ELSE
--			PP.TotMfgLeadTimeSys
--		END AS 'LeadTime',
--		OH.TotalSetupHours AS 'ChildTLSetHrs',
--		OH.TotalProdHours AS 'ChildTLProdHrs',
--		OH.TotalProdStandard AS 'ChildProdStandard',
--		OH.StdFormat,
--		CAST(CTE.Path + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
--		FROM MoMExplosion CTE
--		INNER JOIN erp.partmtl PM ON PM.PartNum = CTE.Child
--		INNER JOIN erp.PartPlant PP	ON PM.MtlPartNum = PP.PartNum 
--		INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
--		INNER JOIN erp.PartWhse PW	ON P.PartNum = PW.PartNum
--		INNER JOIN erp.PartRev PR1	ON PR1.PartNum = PM.PartNum AND PM.RevisionNum = PR1.RevisionNum
--		INNER JOIN OpHours OH ON OH.PartNum = P.PartNum
--		WHERE PP.Plant = 'GLENDN'
--		AND PW.WarehouseCode = '190'
--		AND PR1.Approved = 1
--)
--SELECT * FROM MomExplosion --where path like '%A-A4483%' 
--order by lvl asc, Parent asc, mtlseq asc

--Include total parent explosion parts
WITH OpHours AS (
SELECT 
    PO.PartNum,
	PO.RevisionNum,
    SUM(PO.EstSetHours) AS TotalSetupHours,
    SUM(PO.EstProdHours) AS TotalProdHours,
	SUM(PO.ProdStandard) AS TotalProdStandard,
	PO.StdFormat
FROM erp.PartOpr PO 
INNER JOIN Part ON Part.PartNum = PO.PartNum
INNER JOIN PartRev ON Part.PartNum = PartRev.PartNum AND PartRev.RevisionNum = PO.RevisionNum
WHERE Inactive = 0 AND PartRev.Approved = 1 
GROUP BY PO.PartNum, PO.RevisionNum, PO.StdFormat
), MoMExplosion AS (
	SELECT 
		PM.PartNum AS 'Parent',
		PM.RevisionNum AS 'ParentRevNum',
		PM.MtlSeq,
		PM.MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		PM.QtyPer,
		0 AS 'lvl' ,
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		OH1.TotalSetupHours AS 'ChildTLSetHrs',
		OH1.TotalProdHours AS 'ChildTLProdHrs',
		OH1.TotalProdStandard AS 'ChildProdStandard',
		OH1.StdFormat,
		PM.QtyPer AS 'ParentQty',
		CAST(PM.QtyPer AS Decimal(18,6))AS 'TotalQtyPerTopLevel',
		CAST(PM.QtyPer * OH1.TotalProdHours AS Decimal(18,6)) AS 'TotalProductionHours',
		CAST(PM.PartNum + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
		FROM erp.partmtl PM
		INNER JOIN erp.PartPlant PP	ON PM.MtlPartNum = PP.PartNum 
		INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
		INNER JOIN erp.PartWhse PW ON P.PartNum = PW.PartNum
		INNER JOIN erp.PartRev PR1 ON PR1.PartNum = PM.PartNum AND PM.RevisionNum = PR1.RevisionNum 
		INNER JOIN OpHours OH1 ON OH1.PartNum = P.PartNum
		INNER JOIN OpHours OH2 ON OH2.PartNum = PM.PartNum
		WHERE PM.PartNum = 'A-X0991'
		AND PP.Plant = 'GLENDN'
		AND PW.WarehouseCode = '190'
		AND PR1.Approved = 1
		--AND PR2.Approved = 1
	UNION ALL
	SELECT 
		CTE.Child AS 'Parent',
		PM.RevisionNum AS 'ParentRevNum',
		PM.MtlSeq,
		PM.MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		PM.QtyPer,
		CTE.lvl+1 AS 'lvl' ,
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		OH.TotalSetupHours AS 'ChildTLSetHrs',
		OH.TotalProdHours AS 'ChildTLProdHrs',
		OH.TotalProdStandard AS 'ChildProdStandard',
		OH.StdFormat,
		CTE.QtyPer AS 'ParentQty',
		CAST(CTE.TotalQtyPerTopLevel * PM.QtyPer AS Decimal(18,6)) AS 'TotalQtyPerTopLevel',
		CAST(CTE.TotalQtyPerTopLevel * PM.QtyPer * OH.TotalProdHours AS Decimal(18,6)) AS 'TotalProductionHours',
		CAST(CTE.Path + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
		FROM MoMExplosion CTE
		INNER JOIN erp.partmtl PM ON PM.PartNum = CTE.Child
		INNER JOIN erp.PartPlant PP	ON PM.MtlPartNum = PP.PartNum 
		INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
		INNER JOIN erp.PartWhse PW	ON P.PartNum = PW.PartNum
		INNER JOIN erp.PartRev PR1	ON PR1.PartNum = PM.PartNum AND PM.RevisionNum = PR1.RevisionNum
		INNER JOIN OpHours OH ON OH.PartNum = P.PartNum
		WHERE PP.Plant = 'GLENDN'
		AND PW.WarehouseCode = '190'
		AND PR1.Approved = 1
)
SELECT * FROM MomExplosion
order by lvl asc, Parent asc, mtlseq asc