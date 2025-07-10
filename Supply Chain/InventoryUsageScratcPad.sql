SELECT PartNum,YEAR(sysdate) as 'YEAR',MONTH(sysdate) AS 'Month',SUM(TranQty) AS 'TotalConsumption'
FROM erp.parttran 
WHERE (trantype = 'STK-CUS' 
OR trantype = 'STK-MTL' 
OR trantype = 'STK-ASM' 
OR trantype = 'STK-UKN' )
and sysdate >= '2023-01-01'
GROUP BY PartNum,YEAR(sysdate),MONTH(sysdate)
order by YEAR(sysdate) desc, MONTH(sysdate) asc

SELECT *--PartNum,SUM(TranQty) 
FROM erp.parttran 
WHERE (trantype = 'STK-CUS' 
OR trantype = 'STK-MTL' 
OR trantype = 'STK-ASM' 
OR trantype = 'STK-UKN' )
and partnum = 'gfg-100'
and sysdate <= '2024-08-31'
and sysdate >= '2024-08-01'
and WareHouseCode = '190'
GROUP BY PartNum;

WITH ConsumptionData AS (
    SELECT 
        PartNum,
        CONCAT(YEAR(sysdate), '-', RIGHT(CONCAT('0', MONTH(sysdate)), 2)) AS YearMonth, -- Combines Year and Month
        SUM(TranQty) AS TotalConsumption
    FROM 
        erp.parttran
    WHERE 
        (trantype = 'STK-CUS' 
        OR trantype = 'STK-MTL' 
        OR trantype = 'STK-ASM' 
        OR trantype = 'STK-UKN')
        AND sysdate >= '2023-01-01'
    GROUP BY 
        PartNum, YEAR(sysdate), MONTH(sysdate)
)
SELECT *
FROM ConsumptionData
PIVOT (
    SUM(TotalConsumption) 
    FOR YearMonth IN ([2023-01], [2023-02], [2023-03], [2023-04], [2023-05], 
                      [2023-06], [2023-07], [2023-08], [2023-09], [2023-10], 
                      [2023-11], [2023-12])
) AS PivotedData
ORDER BY PartNum;

DECLARE @cols AS NVARCHAR(MAX),
        @query AS NVARCHAR(MAX);

-- Step 1: Generate a list of Year-Month combinations dynamically
SELECT @cols = STUFF((
    SELECT DISTINCT ',' + QUOTENAME(CONCAT(YEAR(sysdate), '-', RIGHT(CONCAT('0', MONTH(sysdate)), 2)))
    FROM erp.parttran
    WHERE sysdate >= '2023-01-01'
    AND (trantype = 'STK-CUS' 
    OR trantype = 'STK-MTL' 
    OR trantype = 'STK-ASM' 
    OR trantype = 'STK-UKN')
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

-- Step 2: Build the dynamic pivot query
SET @query = '
WITH ConsumptionData AS (
    SELECT 
        PartNum,
        CONCAT(YEAR(sysdate), ''-'', RIGHT(CONCAT(''0'', MONTH(sysdate)), 2)) AS YearMonth,
        SUM(TranQty) AS TotalConsumption
    FROM 
        erp.parttran
    WHERE 
        sysdate >= ''2023-01-01''
        AND (trantype = ''STK-CUS'' 
        OR trantype = ''STK-MTL'' 
        OR trantype = ''STK-ASM'' 
        OR trantype = ''STK-UKN'')
    GROUP BY 
        PartNum, YEAR(sysdate), MONTH(sysdate)
)
SELECT PartNum, ' + @cols + '
FROM ConsumptionData
PIVOT (
    SUM(TotalConsumption) 
    FOR YearMonth IN (' + @cols + ')
) AS PivotedData
ORDER BY PartNum;';

-- Step 3: Execute the dynamic query
EXEC sp_executesql @query;