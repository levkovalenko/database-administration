USE AdventureWorks2019;
GO

CREATE PROCEDURE permissionChecks @user VARCHAR(100) = NULL AS
BEGIN

DECLARE @query VARCHAR(8000) = 'SELECT * FROM ';
DECLARE @mytable table(
    entity_name VARCHAR(100),
    subentity_name VARCHAR(100),
    permission_name VARCHAR(100)
)

-- select curent user as default value
IF @user is NULL
BEGIN
	SET @user = CURRENT_USER
END


-- setup user
EXECUTE AS USER = @user

--get user permissions for each table
SELECT  @user, table_name, permission_name
FROM 
    ( select distinct permission_name from sys.database_permissions where class = 1 ) P
     CROSS APPLY 
    (SELECT  TABLE_SCHEMA + '.' + TABLE_NAME as table_name  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE') L
WHERE HAS_PERMS_BY_NAME(table_name, 'OBJECT', permission_name) = 1
ORDER BY table_name;

END
GO
-- example of use and drop procedure
EXEC permissionChecks
GO
DROP PROCEDURE permissionChecks 
GO
