SELECT * FROM erp.JobHead where jobfirm = 1 and jobclosed = 0

SELECT JobOper.* FROM erp.JobHead 
INNER JOIN erp.JobOper on JobHead.JobNum = JobOper.JobNum
where jobfirm = 1 and jobclosed = 0

