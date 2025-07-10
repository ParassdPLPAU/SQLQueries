WITH BASE AS (
	SELECT 
		CASE 
			WHEN JobNum = LAG(JobNum) OVER (PARTITION BY JobNum ORDER BY DateTimeCaptured)
			THEN 
				CASE 
					WHEN COALESCE(DueDate, '1900-01-01') = COALESCE(LAG(DueDate) OVER (PARTITION BY JobNum ORDER BY DateTimeCaptured),'1900-01-01')
					THEN 'SameDate'
					ELSE 'DateChange'
				END
			ELSE 'NewJob'
		END AS DateChangeStatus,
		*
	FROM dbo.JobHeadData
)
SELECT * FROM BASE
WHERE CAST(DateTimeCaptured AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY JobNum, DateTimeCaptured;

SELECT * 
FROM [PLP_PowerBI].dbo.JobHeadData
WHERE JobNum COLLATE SQL_Latin1_General_CP1_CI_AS IN (
    SELECT JobNum COLLATE SQL_Latin1_General_CP1_CI_AS
    FROM [PLP_LIVE].erp.JobHead 
    WHERE jobclosed = 0 AND SchedLocked = 1 AND JobComplete = 0
);

SELECT * FROM [PLP_PowerBI].dbo.JobHeadData where JobNum = 'J092827'

WITH BASE AS (
	SELECT 
		CASE 
			WHEN JobNum = LAG(JobNum) OVER (PARTITION BY JobNum ORDER BY DateTimeCaptured)
			THEN 
				CASE 
					WHEN COALESCE(DueDate, '1900-01-01') = COALESCE(LAG(DueDate) OVER (PARTITION BY JobNum ORDER BY DateTimeCaptured),'1900-01-01')
					THEN 'SameDate'
					ELSE 'DateChange'
				END
			ELSE 'NewJob'
		END AS DateChangeStatus,
		*
	FROM [PLP_PowerBI].dbo.JobHeadData
	WHERE JobNum COLLATE SQL_Latin1_General_CP1_CI_AS IN (
    SELECT JobNum COLLATE SQL_Latin1_General_CP1_CI_AS
    FROM [PLP_LIVE].erp.JobHead 
    WHERE jobclosed = 0 AND SchedLocked = 1 AND JobComplete = 0
)
)
SELECT * FROM BASE
WHERE DateChangeStatus = 'DateChange'
--WHERE CAST(DateTimeCaptured AS DATE) = CAST(GETDATE() AS DATE)
--ORDER BY JobNum, DateTimeCaptured;
ORDER BY DateTimeCaptured,JobNum;

