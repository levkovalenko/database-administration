-- Разделение

/* 
Задание - написать SQL-код для разделения какой-нибудь реальной таблицы с данными. Реальную таблицу взять из какой-нибудь действующей (настоящей, не "игрушечной") БД.
Можно использовать один из двух сценариев: 
1) создание пустой разделенной таблицы + перенос данных и переименование таблиц
2) применение кластерного индекса
*/

/*
-----------------
Теория и примеры
-----------------
*/

CREATE DATABASE part_demo;

USE part_demo;
GO

-- Partitioning (cекционирование, разделение данных)

-- Для создания таблицы, разделенной на разделы (секции), выполняются следующие действия:

-- 1) создание групп файлов (кол-во групп >= планируемому кол-ву разделов)
-- + создание файлов, входящих в эти группы

ALTER DATABASE part_demo
ADD FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILEGROUP g3;

-- добавление файлов в каждую группу
ALTER DATABASE part_demo
ADD FILE
(
NAME = f1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f1.ndf'
) TO FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILE
(
NAME = f2,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f2.ndf'
) TO FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILE
(
NAME = f3,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f3.ndf'
) TO FILEGROUP g3;

-- 2) создание функции разделения (PARTITION FUNCTION)
-- функция разделения - правило разделения данных определенного типа на дипазоны, задаваемое путем указания граничных значений (т.е. значений, лежащих на границе диапазонов)
-- кол-во разделов = кол-ву граничных значений + 1
CREATE PARTITION FUNCTION my_pf(int) -- функция для трех разделов
AS
RANGE LEFT
FOR VALUES (10, 20)

-- 3) создание схемы разделения (PARTITION SCHEME)
-- схема разделения - объект, выполняющий связь физических хранилищ (групп файлов) и логических диапазонов данных (функции разделения)
-- в дальнейшем схема разделения используется вместо группы файлов для размещения объекта
CREATE PARTITION SCHEME my_ps
AS PARTITION my_pf -- схема основана на функции разделения my_pf
TO (g1, g2, g3) -- и связана с тремя группами файлов (g1, g2, g3)


-- 4) создание новой разделенной таблицы. Таблица основана на созданной ранее схеме разделения, параметром которой указан столбец - ключ разделения
-- тип ключа разделения должен совпадать с типом аргумента функции разделения

CREATE TABLE t1 (c1 int, c2 int)
ON my_ps(c1);

-- теперь наполняем таблицу данными
-- (на практике данные берутся из исходной, неразделенной таблицы)

DECLARE @i int;
SET @i=30;
WHILE (@i<40)
BEGIN
	INSERT INTO t1(c1, c2)
	VALUES (@i, @i+1);
	
	SET @i = @i + 1;
END;


/*
Другим способом перевода имеющейся таблицы на новую схему разделения 
является создание (или пересоздание) кластерного индекса
*/

CREATE CLUSTERED INDEX index_t1_c1
ON t1(c1)
WITH (DROP_EXISTING = ON)
ON my_ps(c1);


-- это выражение позволяет вычислить значение функции разделения (= номеру раздела) для указанного аргумента
$PARTITION.my_pf(int_value_2_calc_partition)

-- пример (кол-во записей в каждой группе разделения)
SELECT COUNT(*) FROM t1
GROUP BY $PARTITION.my_pf(c1)

-- это системные таблицы, содержащие сведения о разделах, функциях разделения, диапазонах, схемах и т.п.
SELECT * FROM sys.partitions
SELECT * FROM sys.partition_functions
SELECT * FROM sys.partition_parameters
SELECT * FROM sys.partition_range_values
SELECT * FROM sys.partition_schemes
SELECT * FROM sys.data_spaces
SELECT * FROM sys.destination_data_spaces 

------------------------------------------------

-- для добавления нового раздела нужна дополнительная группа файлов
ALTER DATABASE part_demo
	ADD FILEGROUP g4;
GO	

ALTER DATABASE part_demo
ADD FILE
(
NAME = f1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f1.ndf'
) TO FILEGROUP g1;

-- меняем схему разделения, добавляя "запасную" группу для будущего раздела, отмеченную как NEXT USED
ALTER PARTITION SCHEME ps_t2
NEXT USED g4

-- добавляем новый раздел к функции разделения (это возможно, если у связанной с ней схемы разделения есть группа NEXT USED)
ALTER PARTITION FUNCTION my_pf()
SPLIT RANGE (30)

-- можно объединить разделы 
ALTER PARTITION FUNCTION my_pf()
MERGE RANGE (30)

-- Можно перенести данные неразделенной таблицы в один из разделов в схеме разделения другой (разделенной) таблицы.
-- Дополнительным требованием к исходной таблице t1 является явное ограничение - CHECK, 
-- обеспечивающее попадание данных столбца разделения в диапазон выбранного раздела (согласно функции разделения).
-- Кроме того, важно, чтобы данные столбца разделения не могли иметь значений NULL (указать NOT NULL при создании столбца или в CHECK). 
-- Это требование не обязательно для первого раздела, который будет соответствовать значениям NULL по диапазону.
ALTER TABLE t1
SWITCH TO t2 PARTITION 1;

