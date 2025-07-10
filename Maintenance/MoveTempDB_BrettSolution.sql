USE tempdb;
GO
SELECT 
    SUM(user_object_reserved_page_count)*8 AS usr_obj_kb,
    SUM(internal_object_reserved_page_count)*8 AS internal_obj_kb,
    SUM(version_store_reserved_page_count)*8 AS version_store_kb,
    SUM(unallocated_extent_page_count)*8 AS unallocated_kb,
    SUM(mixed_extent_page_count)*8 AS mixed_extent_kb
FROM sys.dm_db_file_space_usage;

SELECT 
    t.session_id,
    r.status,
    r.command,
    t.internal_objects_alloc_page_count * 8 AS internal_kb,
    t.user_objects_alloc_page_count * 8 AS user_kb,
    sql.text AS query_text
FROM sys.dm_db_task_space_usage AS t
JOIN sys.dm_exec_requests AS r ON t.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS sql
ORDER BY (t.internal_objects_alloc_page_count + t.user_objects_alloc_page_count) DESC;

SELECT name, physical_name FROM sys.master_files WHERE database_id = DB_ID('tempdb');
SELECT * FROM sys.master_files

SELECT servicename, service_account 
FROM sys.dm_server_services 
WHERE servicename LIKE 'SQL Server (%';

DECLARE @newDriveAndFolder VARCHAR(8000);
SET @newDriveAndFolder = 'D:\Temp';

SELECT [name] AS [Logical Name]
    ,physical_name AS [Current Location]
    ,state_desc AS [Status]
    ,size / 128 AS [Size(MB)] --Number of 8KB pages / 128 = MB
    ,'ALTER DATABASE tempdb MODIFY FILE (NAME = ' + QUOTENAME(f.[name])
    + CHAR(9) /* Tab */
    + ',FILENAME = ''' + @newDriveAndFolder + CHAR(92) /* Backslash */ + f.[name]
    + CASE WHEN f.[type] = 1 /* Log */ THEN '.ldf' ELSE '.mdf' END  + ''''
    + ');'
    AS [Create new TempDB files]
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb')
ORDER BY f.[type];