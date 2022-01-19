-- Резервное копирование и восстановление

/* 
Задание - написать 2 хранимые процедуры:
1) Для создания резервной копии (полной или разностной) заданной БД. Имя БД определяется аргументом процедуры. 
При сохранениии нужно учитывать время создания резервной копии. Рекомендуется задействовать как полную, так и разностную копии.
Можно разработать стратегию для резервного копирования: например, делать полную копию раз в неделю/10 дней/месяц, а разностную - раз в день/12 часов/час.
2) Для восстановления БД из хранимого набора резервных копий с указанием даты/времени, на которую надо восстановить БД.
При наличии нескольких вариантов следует выбирать ближайший по времени (либо ближайший предшествующий) к указанному параметру.

*/

/*

-----------------
Теория и примеры
-----------------

При создании бэкапа мы указываем backup device - файл. 
При указании одного и того же девайса (в частности - файла) для нескольких
последовательно сделанных резервных копий (неважно - полных или разностных), 
они не переписывают его содержание, а просто добавляются в конец (видимо, наследство работы с пленкой "TO TAPE").
Так в одном файле появляется множество копий, которые различаются по номерам (начиная с 1).
Для указания номера бэкапа на девайсе в опциях указывают FILE = 1, 2, ... 
При восстановлении (без указания FILE=...) используется всегда первая версия.

Как этим пользоваться без ошибок (варианты): 

1) Учитывать номер резервной копии при восстновлении

2) В BACKUP DATABASE указывать опцию INIT, которая позволяет переписывать файл заново 

3) давать всем файлам уникальные имена

*/

-- Пусть есть некоторая БД Secure

-- полная 
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_full.bak'
WITH INIT;
GO

-- разностная (только изменения относительно последней полной)
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_diff.bak'
WITH DIFFERENTIAL, INIT;

-- восстановление в исходное место
RESTORE DATABASE Secure
FROM
DISK = 'c:\temp\secure_full.bak'
WITH
NORECOVERY;
GO

RESTORE DATABASE Secure
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
RECOVERY;
GO

-- восстановление в другую БД
RESTORE DATABASE Secure2
FROM
DISK = 'c:\temp\secure_full.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf',
NORECOVERY;
GO

RESTORE DATABASE Secure2
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf',
RECOVERY;
GO

-- проверка целостности архива и возможности восстановления (без восстановления)
RESTORE VERIFYONLY
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf';