
/*
    Script to configure and expand tempdb data files in SQL Server.

    - Sets the primary tempdb data file (tempdev) to a specified size, growth, and unlimited max size.
    - Determines the current number of tempdb data files.
    - Adds additional tempdb data files (up to a total of 8) with consistent size and growth settings.
    - New files are named tempdev1.ndf, tempdev2.ndf, ..., tempdev7.ndf and placed in the same directory as the primary file.
    - Uses dynamic SQL to execute ALTER DATABASE statements for file creation.
    - Prints each ALTER DATABASE command before execution for logging and verification.

    Usage:
        Run this script in the context of the [master] database as a user with sufficient privileges.
        Adjust file size and growth parameters as needed for your environment.

    Note:
        This script is intended for SQL Server environments where tempdb optimization is required.
        Review and test in a non-production environment before applying to production.
        Epicor 10.2.6 PDT tool recommends that you have upto 8 tempdb files in your SQL server, hence this script has filecount hardcoded 
        to create files until 8 are reached.
*/
USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 5120000KB , FILEGROWTH = 204800KB, MAXSIZE = UNLIMITED )
DECLARE @file_count int,
@logical_name sysname,
@file_name nvarchar(520),
@physical_name nvarchar(520),
@alter_command nvarchar(max)
SELECT @physical_name = physical_name
FROM tempdb.sys.database_files
WHERE name = 'tempdev'
SELECT @file_count = COUNT(*)
FROM tempdb.sys.database_files
WHERE type_desc = 'ROWS'
WHILE @file_count < 8
BEGIN
SELECT @logical_name = 'tempdev' + CAST(@file_count AS nvarchar)
SELECT @file_name = REPLACE(@physical_name, 'tempdb.mdf', @logical_name + '.ndf')
SELECT @alter_command = 'ALTER DATABASE [tempdb] ADD FILE ( NAME =N''' + @logical_name + ''', FILENAME =N''' + @file_name + ''', SIZE = 5120000KB, MAXSIZE = UNLIMITED, FILEGROWTH = 204800KB)'
PRINT @alter_command
EXEC sp_executesql @alter_command
SELECT @file_count = @file_count + 1
END
 