USE master;
GO
CREATE PROCEDURE backupProc @targetDatabase VARCHAR(100), @backupDirectory VARCHAR(100) ='/backups/', @daysIntervalFullBackup INT = 30 AS
BEGIN

DECLARE @backupFileName VARCHAR(250),
        @sqlQuery VARCHAR(1000),
        @latestFullBackup VARCHAR(100)

IF CHARINDEX('/', REVERSE(@backupDirectory)) > 1
BEGIN
	SET @backupDirectory = @backupDirectory + '/'
END

-- get latest full backup
SET @latestFullBackup = (
        SELECT 
            msdb.dbo.backupset.database_name
        FROM 
            msdb.dbo.backupset 
        WHERE
            msdb.dbo.backupset.database_name = @targetDatabase AND 
            msdb.dbo.backupset.type = 'D' 
        GROUP BY 
            msdb.dbo.backupset.database_name
        HAVING (
                MAX(msdb.dbo.backupset.backup_finish_date) > 
                DATEADD(dd, - @daysIntervalFullBackup, GETDATE())
            )
)

-- choose backup strategy if last full backup was more thaan 30 dayes, make new full backup 
-- in another case create diff backup
IF @latestFullBackup IS NULL
BEGIN
    SET @backupFileName = @backupDirectory + @targetDatabase + '_full_' + CONVERT(VARCHAR, GETDATE(), 126) +'.bak'
    SET @sqlQuery = 'BACKUP DATABASE ' + @targetDatabase + ' TO DISK = ''' + @backupFileName + ''' WITH INIT'
END
ELSE
BEGIN
    SET @backupFileName = @backupDirectory + @targetDatabase + '_diff_' + CONVERT(VARCHAR, GETDATE(), 126) + '.bak'
    SET @sqlQuery = 'BACKUP DATABASE ' + @targetDatabase + ' TO DISK = ''' + @backupFileName + ''' WITH DIFFERENTIAL, INIT'
END

EXEC(@sqlQuery)
END
GO
-- example of use and drop procedure
EXEC backupProc  @targetDatabase = 'AdventureWorks2019'
GO
DROP PROCEDURE test_backup
GO
