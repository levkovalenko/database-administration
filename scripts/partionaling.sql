USE AdventureWorks2019;
GO

ALTER DATABASE AdventureWorks2019
ADD FILE
(
NAME = f1,
FILENAME = '/var/opt/mssql/data/AdventureWorks2019_f1.ndf'
) TO FILEGROUP g1;
GO

ALTER DATABASE AdventureWorks2019
ADD FILE
(
NAME = f2,
FILENAME = '/var/opt/mssql/data/AdventureWorks2019_f2.ndf'
) TO FILEGROUP g2;
GO

ALTER DATABASE AdventureWorks2019
ADD FILE
(
NAME = f3,
FILENAME = '/var/opt/mssql/data/AdventureWorks2019_f3.ndf'
) TO FILEGROUP g3;
GO


CREATE PARTITION FUNCTION my_part_func(int) 
AS
RANGE LEFT
FOR VALUES (1000, 10000);
GO


CREATE PARTITION SCHEME my_part_schema
AS PARTITION my_part_func 
TO (g1, g2, g3) ;
GO


CREATE CLUSTERED INDEX index_Person_Person_BusinessEntityID
ON Person.Person(BusinessEntityID)
ON my_part_schema(BusinessEntityID);
GO


SELECT COUNT(*) FROM Person.Person GROUP BY $PARTITION.my_part_func(BusinessEntityID);
GO
