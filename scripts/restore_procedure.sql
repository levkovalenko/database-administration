USE master;
GO
CREATE PROCEDURE restoreProc @targetDatabase VARCHAR(100), @targetDatetime DATETIME = NULL AS
BEGIN

DECLARE @backupFileName VARCHAR(250),
        @fullBackupFileName VARCHAR(250),
        @backupType VARCHAR(1),
        @sqlQuery VARCHAR(1000);

IF @targetDatetime IS NULL
BEGIN
    SET @targetDatetime = GETDATE()
END

-- get latest full backup
SELECT
       @fullBackupFileName=x.physical_device_name
FROM (  SELECT  bs.database_name,
                bs.backup_start_date,
                bs.type,
                bmf.physical_device_name,
                  Ordinal = ROW_NUMBER() OVER( PARTITION BY bs.database_name ORDER BY bs.backup_start_date DESC ),
                  PeriodS = DATEDIFF(ss, bs.backup_start_date, @targetDatetime)
          FROM  msdb.dbo.backupmediafamily bmf
                  JOIN msdb.dbo.backupmediaset bms ON bmf.media_set_id = bms.media_set_id
                  JOIN msdb.dbo.backupset bs ON bms.media_set_id = bs.media_set_id
          WHERE  bs.[type] = 'D' AND bs.is_copy_only = 0 ) x
WHERE x.database_name = @targetDatabase and x.PeriodS >= 0
ORDER BY x.backup_start_date;


-- get latest backup 
SELECT
       @backupFileName=x.physical_device_name,
       @backupType=x.type
FROM (  SELECT  bs.database_name,
                bs.backup_start_date,
                bs.type,
                bmf.physical_device_name,
                  Ordinal = ROW_NUMBER() OVER( PARTITION BY bs.database_name ORDER BY bs.backup_start_date DESC ),
                  PeriodS = DATEDIFF(ss, bs.backup_start_date, @targetDatetime)
          FROM  msdb.dbo.backupmediafamily bmf
                  JOIN msdb.dbo.backupmediaset bms ON bmf.media_set_id = bms.media_set_id
                  JOIN msdb.dbo.backupset bs ON bms.media_set_id = bs.media_set_id
          WHERE   bs.is_copy_only = 0 ) x
WHERE x.database_name = @targetDatabase and x.PeriodS >= 0
ORDER BY x.backup_start_date;


-- choose way of backup restore: only full or full and diff backups
IF @backupType = 'D'
BEGIN
    SET @sqlQuery = 'RESTORE DATABASE ' + @targetDatabase + ' FROM DISK = ''' + @backupFileName + ''' WITH NORECOVERY'
END
ELSE
BEGIN
    SET @sqlQuery = 'RESTORE DATABASE ' + @targetDatabase + ' FROM DISK = ''' + @fullBackupFileName + ''' WITH NORECOVERY'
    EXEC(@sqlQuery)
    SET @sqlQuery = 'RESTORE DATABASE ' + @targetDatabase + ' FROM DISK = ''' + @backupFileName + ''' WITH RECOVERY'
END

EXEC(@sqlQuery)

END

-- example of use and drop procedure
GO
EXEC restoreProc  @targetDatabase = 'AdventureWorks2019', @targetDatetime = '2022-01-19 13:07:36.000'
GO
DROP PROCEDURE restoreProc
GO
