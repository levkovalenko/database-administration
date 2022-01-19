-- Проверка и вывод прав 

-- Задание. Написать хранимую процедуру, выдающую все права пользователя на действия в каждой таблице текущей БД

/*
стандартными средствами вывод всех прав пользователя не сделать,
однако в T-SQL существует 2 типовых средства проверки прав на конкретный объект 
*/

-- 1) процедура fn_my_permissions
-- вывод всех имеющихся прав на выбранный объект (для подключенного пользователя)

-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-my-permissions-transact-sql


-- все права уровня сервера
SELECT * FROM fn_my_permissions (NULL, 'SERVER');
 
-- все права уровня базы данных
SELECT * FROM fn_my_permissions (NULL, 'DATABASE');

-- все права на конкретный объект (таблицу - 'Action')
SELECT * FROM fn_my_permissions ('Action', 'OBJECT');


-- 2) функция HAS_PERMS_BY_NAME 
-- проверка конкретного разрешения на выбранный объект (для подключенного пользователя)
-- возвращает 1 (есть разрешение), 0 (нет разрешения) или NULL - ошибка в именах сущностей

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/has-perms-by-name-transact-sql


-- проверка права создания БД 
-- названия разрешений - SELECT * FROM fn_my_permissions (NULL, 'SERVER')
SELECT HAS_PERMS_BY_NAME(NULL, NULL, 'CREATE ANY DATABASE');

-- проверка права создания таблицы в текущей БД
-- названия разрешений - SELECT * FROM fn_my_permissions (NULL, 'DATABASE')
SELECT HAS_PERMS_BY_NAME (NULL, 'DATABASE', 'CREATE TABLE');

-- проверка возможности выборки из таблицы ('Action')
-- названия разрешений - SELECT * FROM fn_my_permissions ('Action', 'OBJECT')
SELECT HAS_PERMS_BY_NAME ('sysdatabases', 'OBJECT', 'SELECT');
