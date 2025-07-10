--BoM Explosion
WITH PartsExplosion AS (
	SELECT 
		PM.PartNum AS 'Parent',
		PM.RevisionNum AS 'ParentRevNum',
		PM.MtlSeq,
		MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		PP.NonStock,
		PR.Approved,
		PM.QtyPer,
		PM.PullAsAsm,
		0 AS 'lvl' ,
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		PP.DaysOfSupply,
		P.Constrained,
		PP.PersonID,
		PP.SafetyQty,
		PW.DemandQty,
		PW.OnHandQty,
		PP.MfgLotSize,
		CAST(PM.PartNum + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
	FROM erp.partmtl PM
	INNER JOIN [PLP_LIVE].erp.PartPlant PP ON PM.MtlPartNum = PP.PartNum 
	INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW ON P.PartNum = PW.PartNum
	INNER JOIN erp.PartRev PR ON PR.PartNum = PM.PartNum AND PM.RevisionNum = PR.RevisionNum
	--AND PR.Approved = 1
	WHERE PM.PartNum = 'A-X0989'
	AND PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
	AND PR.Approved = 1
	UNION ALL
	SELECT 
		CTE.Child AS 'Parent',
		BoM.RevisionNum AS 'ParentRevNum',
		BoM.MtlSeq, 
		BoM.MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		PP.NonStock,
		PR.Approved,
		BoM.QtyPer,
		BoM.PullAsAsm,
		CTE.lvl+1 AS 'lvl' ,
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		PP.DaysOfSupply,
		P.Constrained,
		PP.PersonID,
		PP.SafetyQty,
		PW.DemandQty,
		PW.OnHandQty,
		PP.MfgLotSize,
		CAST(CTE.Path + ' -> ' + BoM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Append child part to the path
	FROM PartsExplosion CTE
	INNER JOIN erp.partmtl BoM ON BoM.PartNum = CTE.Child 
	INNER JOIN [PLP_LIVE].erp.PartPlant PP ON PP.PartNum = BoM.MtlPartNum
	INNER JOIN erp.Part P ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW ON P.PartNum = PW.PartNum
	INNER JOIN erp.PartRev PR ON PR.PartNum = BoM.PartNum AND BoM.RevisionNum = PR.RevisionNum
	--AND PR.Approved = 1
	WHERE PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
	AND PR.Approved = 1
)
SELECT * FROM PartsExplosion order by lvl asc, Parent asc, MtlSeq asc,LeadTime asc;
Select * from erp.partrev where partnum = 'D-ALV300'
Select * from erp.partmtl where partnum = 'D-ALV300'
--BoM Implosion
WITH ReverseBoM AS (
	SELECT 
		MtlPartNum AS 'Child',
		PM.PartNum AS 'Parent',
		MtlSeq,
		QtyPer,
		PullAsAsm,
		0 AS 'lvl',
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		PP.DaysOfSupply,
		P.Constrained,
		PP.SafetyQty,
		PW.DemandQty,
		PW.OnHandQty,
		CAST(MtlPartNum + ' -> ' + PM.PartNum AS NVARCHAR(MAX)) AS 'Path'
	FROM 
		erp.partmtl PM
	INNER JOIN erp.PartPlant PP
	ON PM.MtlPartNum = PP.PartNum 
	INNER JOIN erp.Part P
	ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW
	ON P.PartNum = PW.PartNum
	WHERE 
		MtlPartNum = 'CFG-100' -- Start with a specific child part
	AND	PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
	UNION ALL
	SELECT 
		MAIN.Parent AS 'Child',
		PM.PartNum AS 'Parent',
		PM.MtlSeq,
		PM.QtyPer,
		PM.PullAsAsm,
		MAIN.lvl+1 AS 'lvl',
		P.InActive,
		PP.PlanTimeFence,
		CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
		PP.DaysOfSupply,
		P.Constrained,
		PP.SafetyQty,
		PW.DemandQty,
		PW.OnHandQty,
		CAST(MAIN.Path + ' -> ' +  PM.PartNum AS NVARCHAR(MAX)) AS 'Path'
	FROM 
		ReverseBoM MAIN 
	INNER JOIN erp.PartMtl PM 
	ON PM.MtlPartNum = MAIN.Parent
	INNER JOIN erp.PartPlant PP
	ON PP.PartNum = MAIN.Child
	INNER JOIN erp.Part P
	ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW
	ON P.PartNum = PW.PartNum
	WHERE PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
)
--select * from erp.PartMtl
-- Select all levels of the reverse BoM hierarchy, starting from the lowest level child
SELECT * FROM ReverseBoM ORDER BY lvl DESC; -- Order by descending level, so you go from bottom to top

SELECT 
	PP.Plant,
	PW.WarehouseCode,
	PP.PartNum,
	PP.SourceType AS 'ChildType',
	P.ProdCode AS 'ProdGroup',
	P.ClassID AS 'PartClass',
	PP.PlanTimeFence,
	CASE WHEN
			PP.SourceType = 'P'
			THEN PP.LeadTime
			ELSE
			PP.TotMfgLeadTimeSys
		END AS 'LeadTime',
	PP.DaysOfSupply,
	PP.MultiLevelCTP,
	PP.MfgLotSize,
	CASE WHEN PP.SourceType = 'P' THEN PP.MinOrderQty
	ELSE PP.MinMfgLotSize 
	END AS 'MOQ',
	PP.MfgLotMultiple AS 'LotMultiple',
	PP.MaxMfgLotSize AS 'MaxLotSize',
	PP.ReschedOutDelta,
	PP.ReschedInDelta,
	PP.KitTime,
	PP.ReceiveTime,
	P.Constrained,
	PP.SafetyQty,
	PW.DemandQty,
	PW.OnHandQty
FROM Part P
INNER JOIN PartPlant PP
ON PP.PartNum = P.PartNum
INNER JOIN erp.PartWhse PW
ON P.PartNum = PW.PartNum
WHERE P.InActive = 0

SELECT * FROM erp.JobAsmbl where JobComplete = 0