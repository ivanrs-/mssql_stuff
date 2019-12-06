USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_reindexDataBases]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Step 2, Prefix with sp_ the custom proc
ALTER PROCEDURE [dbo].[sp_reindexDataBases]
AS
BEGIN
    DECLARE @Database VARCHAR(255)
    DECLARE @Table VARCHAR(255)
    DECLARE @cmd NVARCHAR(500)
    DECLARE @fillfactor INT
    DECLARE @EndTime   DATETIME
    DECLARE @StartTime DATETIME

    SET @fillfactor = 90
    SET @StartTime = GETDATE()

    DECLARE DatabaseCursor CURSOR FOR  
	SELECT name
    FROM master.dbo.sysdatabases
    WHERE name IN (	'{DB_Name}','{DB2_Name}','{DB3_Name}') 
    ORDER BY 1

    PRINT 'Automated Reindexing Process for {SQL SERVER NAME}'
    PRINT '-----------------------------------------------'

    OPEN DatabaseCursor
    FETCH NEXT FROM DatabaseCursor INTO @Database
    WHILE @@FETCH_STATUS = 0  
	BEGIN

        SET @StartTime = GETDATE()
        PRINT 'Current DB: ' + @Database
        PRINT '-----------------------------------------------'

        SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' + 
		table_name + '']'' as tableName FROM [' + @Database + '].INFORMATION_SCHEMA.TABLES 
		WHERE table_type = ''BASE TABLE'''

        -- create table cursor  
        EXEC (@cmd)
        OPEN TableCursor

        FETCH NEXT FROM TableCursor INTO @Table
        PRINT '* Reindexing database tables' + ' ...'

        WHILE @@FETCH_STATUS = 0
		BEGIN
            PRINT @Table
            DBCC DBREINDEX(@Table,' ',90) WITH NO_INFOMSGS
            FETCH NEXT FROM TableCursor INTO @Table
        END

        CLOSE TableCursor
        DEALLOCATE TableCursor

        SET @EndTime = GETDATE()
        PRINT 'Duration: ' + CAST(DATEDIFF(mi,@StartTime,@EndTime) as NVARCHAR) + ' minutes'
        PRINT '-----------------------------------------------'

        FETCH NEXT FROM DatabaseCursor INTO @Database
    END

    CLOSE DatabaseCursor
    DEALLOCATE DatabaseCursor

    SET @EndTime = GETDATE()
    PRINT 'Process Started   : ' + CONVERT(VARCHAR(30),@StartTime,121)
    PRINT 'Process Completed : ' + CONVERT(VARCHAR(30),@EndTime,121) + char(13)
    PRINT 'Contact  : Contact <contact@email.com>'    
    PRINT ':)'
END
