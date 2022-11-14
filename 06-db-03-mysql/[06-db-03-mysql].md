# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

- Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
  ```docker-compose.yml
  version: '3.9'

  services:
    my_db:
      image: mysql:8.0
      container_name: my_db
      restart: always
      environment:
        MYSQL_DATABASE: 'test_db'
        MYSQL_ROOT_PASSWORD: 'netology'
      ports:
        - '3306:3306'
      expose:
        - '3306'
      volumes:
        - ./my-db:/var/lib/mysql
        - ./backup:/media/mysql/backup
        - ./config:/etc/my.cnf.d
  ```
  * ![my_db](img/db.png)

- Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и восстановитесь из него.
    ```
    ash-4.4# ls -la /media/mysql/backup
    total 12
    drwxr-xr-x 2 root root 4096 Jul 23 10:43 .
    drwxr-xr-x 3 root root 4096 Jul 23 10:44 ..
    -rw------- 1 1000 1000 2073 Apr 15 08:04 test_dump.sql
    bash-4.4# mysql -u root -p test_db < /media/mysql/backup/test_dump.sql
    ```
- Перейдите в управляющую консоль `mysql` внутри контейнера.
    ```
    boliwar@netology:~$ sudo docker exec -it my_db mysql -u root -p
    [sudo] пароль для boliwar:
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 20
    Server version: 8.0.29 MySQL Community Server - GPL

    Copyright (c) 2000, 2022, Oracle and/or its affiliates.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql>
    ```
- Используя команду `\h` получите список управляющих команд.
    ```
    List of all MySQL commands:
    Note that all text commands must be first on line and end with ';'
    ?         (\?) Synonym for `help'.
    clear     (\c) Clear the current input statement.
    connect   (\r) Reconnect to the server. Optional arguments are db and host.
    delimiter (\d) Set statement delimiter.
    edit      (\e) Edit command with $EDITOR.
    ego       (\G) Send command to mysql server, display result vertically.
    exit      (\q) Exit mysql. Same as quit.
    go        (\g) Send command to mysql server.
    help      (\h) Display this help.
    nopager   (\n) Disable pager, print to stdout.
    notee     (\t) Don't write into outfile.
    pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
    print     (\p) Print current command.
    prompt    (\R) Change your mysql prompt.
    quit      (\q) Quit mysql.
    rehash    (\#) Rebuild completion hash.
    source    (\.) Execute an SQL script file. Takes a file name as an argument.
    status    (\s) Get status information from the server.
    system    (\!) Execute a system shell command.
    tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
    use       (\u) Use another database. Takes database name as argument.
    charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
    warnings  (\W) Show warnings after every statement.
    nowarning (\w) Don't show warnings after every statement.
    resetconnection(\x) Clean session context.
    query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
    ssl_session_data_print Serializes the current SSL session data to stdout or file
    ```
- Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
    ```
    mysql> \s
    --------------
    mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)
    Connection id:		19
    Current database:
    Current user:		root@localhost
    SSL:			Not in use
    Current pager:		stdout
    Using outfile:		''
    Using delimiter:	;
    Server version:		8.0.29 MySQL Community Server - GPL
    Protocol version:	10
    Connection:		Localhost via UNIX socket
    Server characterset:	utf8mb4
    Db     characterset:	utf8mb4
    Client characterset:	latin1
    Conn.  characterset:	latin1
    UNIX socket:		/var/run/mysqld/mysqld.sock
    Binary data as:		Hexadecimal
    Uptime:			1 hour 7 min 24 sec

    Threads: 4  Questions: 126  Slow queries: 0  Opens: 200  Flush tables: 3  Open tables: 119  Queries per second avg: 0.031
    ```

- Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```

```
**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

- Создайте пользователя test в БД c паролем test-pass, используя:
    - плагин авторизации mysql_native_password
    - срок истечения пароля - 180 дней
    - количество попыток авторизации - 3
    - максимальное количество запросов в час - 100
    - аттрибуты пользователя:
        - Фамилия "Pretty"
        - Имя "James"
    ```
    mysql> CREATE USER 'test'@'localhost'
        ->     IDENTIFIED WITH mysql_native_password BY 'test-pass'
        ->     WITH MAX_CONNECTIONS_PER_HOUR 100
        ->     PASSWORD EXPIRE INTERVAL 180 DAY
        ->     FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
        ->     ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
    Query OK, 0 rows affected (0.01 sec)
    ```
- Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    ```
    mysql> GRANT SELECT ON test_db.* TO test@localhost;
    Query OK, 0 rows affected, 1 warning (0.00 sec)
    ```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.
    * ![test](img/test.png)
## Задача 3

- Установите профилирование `SET profiling = 1`.
- Изучите вывод профилирования команд `SHOW PROFILES;`.

- Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
    * InnoDB

- Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
    - на `MyISAM`
    - на `InnoDB`
    * ![PROFILE](img/profile.png)
## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

- Приведите в ответе измененный файл `my.cnf`.
    ```
    # For advice on how to change settings please see
    # http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

    [mysqld]
    #
    # Remove leading # and set to the amount of RAM for the most important data
    # cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
    # innodb_buffer_pool_size = 128M
    #
    # Remove leading # to turn on a very important data integrity option: logging
    # changes to the binary log between backups.
    # log_bin
    #
    # Remove leading # to set options mainly useful for reporting servers.
    # The server defaults are faster for transactions and fast SELECTs.
    # Adjust sizes as needed, experiment to find the optimal values.
    # join_buffer_size = 128M
    # sort_buffer_size = 2M
    # read_rnd_buffer_size = 2M

    # Remove leading # to revert to previous value for default_authentication_plugin,
    # this will increase compatibility with older clients. For background, see:
    # https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
    # default-authentication-plugin=mysql_native_password
    skip-host-cache
    skip-name-resolve
    datadir=/var/lib/mysql
    socket=/var/run/mysqld/mysqld.sock
    secure-file-priv=/var/lib/mysql-files
    user=mysql

    pid-file=/var/run/mysqld/mysqld.pid
    [client]
    socket=/var/run/mysqld/mysqld.sock

    innodb_flush_log_at_trx_commit = 0
    innodb_file_per_table = ON
    innodb_log_buffer_size = 1M
    innodb_buffer_pool_size = 2G
    innodb_log_file_size = 100M
    ```
