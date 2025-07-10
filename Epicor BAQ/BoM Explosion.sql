--BoM Explosion
WITH PartsExplosion AS (
	SELECT 
		PM.PartNum AS 'Parent',
		MtlSeq,
		MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		QtyPer,
		PullAsAsm,
		0 AS 'lvl' ,
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
		CAST(PM.PartNum + ' -> ' + PM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Start the path with the parent part
	FROM erp.partmtl PM
	INNER JOIN erp.PartPlant PP
	ON PM.MtlPartNum = PP.PartNum 
	INNER JOIN erp.Part P
	ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW
	ON P.PartNum = PW.PartNum
	WHERE PM.PartNum = 'A-X0991' --This is where we require user input. Add this as a parameter.
	AND PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
	UNION ALL
	SELECT 
		CTE.Child AS 'Parent',
		BoM.MtlSeq, 
		BoM.MtlPartNum AS 'Child', 
		PP.SourceType AS 'ChildType',
		Bom.QtyPer,
		Bom.PullAsAsm,
		CTE.lvl+1 AS 'lvl' ,
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
		CAST(CTE.Path + ' -> ' + BoM.MtlPartNum AS NVARCHAR(MAX)) AS 'Path' -- Append child part to the path
	FROM PartsExplosion CTE
	INNER JOIN erp.partmtl Bom 
	ON Bom.PartNum = CTE.Child 
	INNER JOIN erp.PartPlant PP
	ON PP.PartNum = BoM.MtlPartNum
	INNER JOIN erp.Part P
	ON PP.PartNum = P.PartNum
	INNER JOIN erp.PartWhse PW
	ON P.PartNum = PW.PartNum
	WHERE PP.Plant = 'GLENDN'
	AND PW.WarehouseCode = '190'
)
SELECT * FROM PartsExplosion order by lvl asc, Parent asc, MtlSeq asc,LeadTime asc;