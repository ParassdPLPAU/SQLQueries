SELECT * FROM DatabaseSizeHistory

SELECT name, recovery_model_desc 
FROM sys.databases 
WHERE name IN ('PLP_LIVE', 'PLP_PILOT');

DBCC SQLPERF(LOGSPACE);


SELECT name, size * 8 / 1024 AS size_MB, growth, is_percent_growth
FROM sys.master_files
WHERE database_id IN (DB_ID('PLP_LIVE'))--, DB_ID('PLP_PILOT'));

USE PLP_LIVE;
EXEC sp_helpfile; --10542MB

ALTER DATABASE PLP_LIVE SET RECOVERY SIMPLE;

USE PLP_LIVE;
DBCC SHRINKFILE (EpicorLive10_log, 10000); -- Shrink to 10GB

ALTER DATABASE PLP_LIVE 
MODIFY FILE (NAME = 'EpicorLive10_log', FILEGROWTH = 256MB);

--BACKUP LOG PLP_LIVE 
--TO DISK = 'D:\SQL_Backups\PLP_PILOT_LogBackup.trn';


SELECT 
    physical_memory_in_use_kb / 1024 AS MemoryUsedMB,
    locked_page_allocations_kb / 1024 AS LockedPagesMB,
    total_virtual_address_space_kb / 1024 AS VirtualAddressSpaceMB,
    virtual_address_space_reserved_kb / 1024 AS VASReservedMB,
    virtual_address_space_committed_kb / 1024 AS VASCommittedMB
FROM sys.dm_os_process_memory;

EXEC sp_configure 'min server memory (MB)';
EXEC sp_configure 'max server memory (MB)';

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Safe settings for 80 GB total RAM, reserving ~12 GB for OS
EXEC sp_configure 'min server memory (MB)', 16384;   -- 16 GB
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 69632;   -- 68 GB
RECONFIGURE;

SELECT 
        GETDATE() AS CaptureDate,
        DB_NAME() AS DatabaseName,
        CAST(total_log_size_in_bytes / 1048576.0 AS DECIMAL(18,2)) AS LogSizeMB,
        CAST(used_log_space_in_bytes / 1048576.0 AS DECIMAL(18,2)) AS LogSpaceUsedMB,
        CAST(used_log_space_in_percent AS DECIMAL(5,2)) AS LogSpaceUsedPercent
    FROM sys.dm_db_log_space_usage;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LogSpaceHistory')
BEGIN
    CREATE TABLE LogSpaceHistory (
        CaptureDate DATETIME,
        DatabaseName NVARCHAR(128),
        LogSizeMB DECIMAL(18,2),
        LogSpaceUsedPercent DECIMAL(5,2),
        LogStatus NVARCHAR(32)
    );
END

IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL
    DROP TABLE #LogSpace;

CREATE TABLE #LogSpace (
    DatabaseName NVARCHAR(128),
    LogSizeMB DECIMAL(18,2),
    LogSpaceUsedPercent DECIMAL(5,2),
    LogStatus NVARCHAR(32)
);

-- Insert DBCC SQLPERF output into temp table
INSERT INTO #LogSpace (DatabaseName, LogSizeMB, LogSpaceUsedPercent, LogStatus)
EXEC ('DBCC SQLPERF(LOGSPACE)');

SELECT * FROM #LogSpace

-- STEP 3: Insert from temp table into LogSpaceHistory with current timestamp
INSERT INTO LogSpaceHistory (CaptureDate, DatabaseName, LogSizeMB, LogSpaceUsedPercent, LogStatus)
SELECT 
    GETDATE() AS CaptureDate,
    DatabaseName,
    LogSizeMB,
    LogSpaceUsedPercent,
    LogStatus
FROM #LogSpace;

-- Optional: Clean up temp table
DROP TABLE #LogSpace;

SELECT * FROM dbo.LogSpaceHistory