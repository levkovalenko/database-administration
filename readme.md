# Получить доступ к консоли базы данных
```sh
docker-compose up -d 
docker exec -it mssql /bin/bash
```


## развернуть exaple database
скачать в папку ./backups [эту базу](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2019.bak)

`/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'axcaxs123QWE' -i /scripts/load_db_test.sql`

## сделать бекап
`/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'axcaxs123QWE' -i /scripts/backup_procedure.sql`

## воставносить из бекапа
`/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'axcaxs123QWE' -i /scripts/restore_procedure.sql`
