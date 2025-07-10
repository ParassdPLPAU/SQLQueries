--SELECT TOP(100) * FROM erp.ShipDtl where partnum = 'BBSA-200-RR-2'
--SELECT TOP(100) * FROM erp.ShipHead 

--SELECT TOP(100) * FROM erp.ShipHead SH inner join erp.ShipDtl SD ON SH.PackNum = SD.PackNum where SD.partnum = 'BBSA-200-RR-2'

--SELECT TOP(100) * FROM erp.PartAlloc where partnum = 'BBSA-200-RR-2'

--SELECT TOP (100)* from erp.JobOper where jobcomplete = 0

--SELECT TOP (100)* from erp.JobMtl where jobcomplete = 0 order by jobnum desc

--SELECT TOP (100)* from erp.LaborDtl order by payrolldate desc

WITH OPERATION_START AS (
	SELECT JO.JobComplete,JO.OpComplete AS 'JOOpComplete',JO.JobNum AS 'JOJobNum',JO.AssemblySeq AS 'JOAssemblySeq',JO.OprSeq AS 'JOOprSeq',JO.OpCode,JO.EstSetHours,JO.EstProdHours,JO.ActProdHours,
	JO.ActSetupHours,JO.StartDate,JO.DueDate,JO.QtyCompleted,
	JO.PartNum,JO.RunQty,LD.EmployeeNum,LD.LaborHedSeq,LD.LaborDtlSeq,LD.LaborType,LD.JobNum,LD.AssemblySeq,LD.OprSeq,LD.JCDept,LD.ResourceGrpID,LD.OpCode AS 'LDOpCode',LD.LaborHrs,LD.BurdenHrs,LD.LaborQty,
	LD.ClockInDate,LD.ClockInTime,LD.ClockOutTime,LD.ActiveTrans,LD.ResourceID,LD.OpComplete,LD.EarnedHrs,LD.PayrollDate,LD.CreatedBy,LD.CreateDate,LD.ChangedBy,LD.ChangeDate FROM erp.JobOper JO
	INNER JOIN erp.LaborDtl LD
	ON JO.JobNum = LD.JobNum
	AND JO.AssemblySeq = LD.AssemblySeq
	AND JO.OprSeq = LD.OprSeq
),
MATERIAL_ISSUED AS (
	SELECT JobComplete,JobNum,AssemblySeq,MtlSeq,PartNum,RequiredQty,IssuedQty,IUM,RelatedOperation,ReqDate FROM erp.JobMtl JM
	WHERE RequiredQty > IssuedQty
)

SELECT OS.JobComplete,OS.OpComplete,OS.JOJobNum,OS.PartNum,MI.PartNum,OS.JOAssemblySeq,OS.OprSeq,OS.OpCode,OS.StartDate,OS.DueDate,OS.QtyCompleted,MI.IssuedQty,MI.RequiredQty,OS.EmployeeNum,OS.LaborDtlSeq,OS.LaborType,OS.JobNum,OS.AssemblySeq,OS.LDOpCode,
OS.LaborHrs,OS.BurdenHrs,OS.LaborQty,OS.ClockInDate,OS.ClockinTime,OS.ClockOutTime,OS.ActiveTrans,OS.ResourceGrpID,OS.ResourceID
FROM OPERATION_START OS
INNER JOIN MATERIAL_ISSUED MI
ON OS.JobNum = MI.JobNum
AND OS.AssemblySeq = MI.AssemblySeq
AND OS.LaborType = 'P'

with [SubQuery2] as 
(select 
                [JobOper].[Company] as [JobOper_Company],
                [JobOper].[JobNum] as [JobOper_JobNum],
                [JobOper].[OprSeq] as [JobOper_OprSeq],
                [JobOper].[OpDesc] as [JobOper_OpDesc],
                [JobOper].[AssemblySeq] as [JobOper_AssemblySeq],
                (Min(LaborDtl.ClockInDate)) as [Calculated_OprStartDate],
                [LaborDtl].[EmployeeNum] as [LaborDtl_EmployeeNum],
                [LaborDtl].[LaborHrs] as [LaborDtl_LaborHrs],
                [LaborDtl].[LaborQty] as [LaborDtl_LaborQty]
from Erp.JobOper as JobOper
inner join Erp.LaborDtl as LaborDtl on 
                JobOper.Company = LaborDtl.Company
                and JobOper.JobNum = LaborDtl.JobNum
                and JobOper.AssemblySeq = LaborDtl.AssemblySeq
                and JobOper.OprSeq = LaborDtl.OprSeq
                and ( LaborDtl.ClockInDate <= GETDATE()  )

where (JobOper.OpComplete = 0  and JobOper.OprSeq = 10)
group by [JobOper].[Company],
                [JobOper].[JobNum],
                [JobOper].[OprSeq],
                [JobOper].[OpDesc],
                [JobOper].[AssemblySeq],
                [LaborDtl].[EmployeeNum],
                [LaborDtl].[LaborHrs],
                [LaborDtl].[LaborQty])
,[SubQuery3] as 
(select 
                [JobMtl].[Company] as [JobMtl_Company],
                [JobMtl].[JobNum] as [JobMtl_JobNum],
                (Sum(JobMtl.IssuedQty)) as [Calculated_SumQtyIssued]
from Erp.JobMtl as JobMtl
group by [JobMtl].[Company],
                [JobMtl].[JobNum])

select 
                [JobHead].[JobNum] as [JobHead_JobNum],
                [SubQuery2].[JobOper_OprSeq] as [JobOper_OprSeq],
                [SubQuery2].[JobOper_OpDesc] as [JobOper_OpDesc],
                [SubQuery2].[JobOper_AssemblySeq] as [JobOper_AssemblySeq],
                [SubQuery2].[Calculated_OprStartDate] as [Calculated_OprStartDate]
from Erp.JobHead as JobHead
inner join  SubQuery2  as SubQuery2 on 
                JobHead.Company = SubQuery2.JobOper_Company
                and JobHead.JobNum = SubQuery2.JobOper_JobNum
inner join  SubQuery3  as SubQuery3 on 
                JobHead.Company = SubQuery3.JobMtl_Company
                and JobHead.JobNum = SubQuery3.JobMtl_JobNum
                and ( SubQuery3.Calculated_SumQtyIssued = 0  )

where (JobHead.JobClosed = 0  and JobHead.JobFirm = 1)
