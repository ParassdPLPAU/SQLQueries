--BoM Implosion
WITH ReverseBoM AS (
	SELECT 
		MtlPartNum AS 'Child',
		PM.PartNum AS 'Parent',
		MtlSeq,
		QtyPer,
		PullAsAsm,
		0 AS 'lvl',
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
		MtlPartNum = 'RMRSS-32.0-GR304' --This is where we require user input. Add this as a parameter.
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

-- Select all levels of the reverse BoM hierarchy, starting from the lowest level child
SELECT * FROM ReverseBoM ORDER BY lvl DESC;