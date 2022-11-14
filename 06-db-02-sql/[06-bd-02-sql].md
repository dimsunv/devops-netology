# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```
version: "3.8"

networks:
  database:
    driver: bridge
services:
  database:
    image: "postgres:14-bullseye"
    container_name: postgres14
    networks:
      - database
    ports:
      - 5432:5432
    environment:
      POSTGRES_USER: test-admin-user # The PostgreSQL user (useful to connect to the database)
      POSTGRES_PASSWORD: PassW0rd # The PostgreSQL password (useful to connect to the database)
      POSTGRES_DB: test-db # The PostgreSQL default database (automatically created at first launch)
    volumes:
      - ./db-data/:/var/lib/postgresql/data/
      - ./backup/:/media/postgresql/backup
    restart: always
```
## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-user  
- предоставьте пользователю test-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
    ```
    test-db=# \l+
                                                                                   List of databases
       Name    |      Owner      | Encoding |  Collate   |   Ctype    |            Access privileges            |  Size   | Tablespace |                Descrip
    tion                 
    -----------+-----------------+----------+------------+------------+-----------------------------------------+---------+------------+-----------------------
    ---------------------
     postgres  | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 |                                         | 8553 kB | pg_default | default administrative
     connection database
     template0 | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"test-admin-user"                   +| 8401 kB | pg_default | unmodifiable empty dat
    abase
               |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user" |         |            | 
     template1 | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"test-admin-user"                   +| 8401 kB | pg_default | default template for n
    ew databases
               |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user" |         |            | 
     test-db   | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/"test-admin-user"                  +| 8737 kB | pg_default | 
               |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user"+|         |            | 
               |                 |          |            |            | "test-user"=c/"test-admin-user"         |         |            | 
    (4 rows)
    ```
- описание таблиц (describe)
    ```
    test-db=# \d+ clients
                                                                    Table "public.clients"
          Column       |     Type      | Collation | Nullable |               Default               | Storage  | Compression | Stats target | Description 
    -------------------+---------------+-----------+----------+-------------------------------------+----------+-------------+--------------+-------------
     id                | integer       |           | not null | nextval('clients_id_seq'::regclass) | plain    |             |              | 
     фамилия           | character(20) |           |          |                                     | extended |             |              | 
     страна проживания | character(20) |           |          |                                     | extended |             |              | 
     заказ             | integer       |           |          |                                     | plain    |             |              | 
    Indexes:
        "clients_pkey" PRIMARY KEY, btree (id)
        "clients_страна проживания_idx" btree ("страна проживания")
    Foreign-key constraints:
        "fk_заказ" FOREIGN KEY ("заказ") REFERENCES orders(id)
    Access method: heap
    
    test-db=# \d+ orders
                                                                 Table "public.orders"
        Column    |     Type      | Collation | Nullable |              Default               | Storage  | Compression | Stats target | Description 
    --------------+---------------+-----------+----------+------------------------------------+----------+-------------+--------------+-------------
     id           | integer       |           | not null | nextval('orders_id_seq'::regclass) | plain    |             |              | 
     наименование | character(20) |           |          |                                    | extended |             |              | 
     цена         | integer       |           |          |                                    | plain    |             |              | 
    Indexes:
        "orders_pkey" PRIMARY KEY, btree (id)
    Referenced by:
        TABLE "clients" CONSTRAINT "fk_заказ" FOREIGN KEY ("заказ") REFERENCES orders(id)
    Access method: heap
    ```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
    ```
    SELECT 
        grantee, table_name, privilege_type 
    FROM 
        information_schema.table_privileges 
    WHERE 
        grantee in ('test-admin-user','test-user')
        and table_name in ('clients','orders')
    order by grantee, table_name;
    ```
- список пользователей с правами над таблицами test_db
    ```
         grantee     | table_name | privilege_type 
    -----------------+------------+----------------
     test-admin-user | clients    | TRIGGER
     test-admin-user | clients    | REFERENCES
     test-admin-user | clients    | TRUNCATE
     test-admin-user | clients    | DELETE
     test-admin-user | clients    | INSERT
     test-admin-user | clients    | SELECT
     test-admin-user | clients    | UPDATE
     test-admin-user | orders     | INSERT
     test-admin-user | orders     | SELECT
     test-admin-user | orders     | UPDATE
     test-admin-user | orders     | DELETE
     test-admin-user | orders     | TRUNCATE
     test-admin-user | orders     | REFERENCES
     test-admin-user | orders     | TRIGGER
     test-user       | clients    | DELETE
     test-user       | clients    | INSERT
     test-user       | clients    | SELECT
     test-user       | clients    | UPDATE
     test-user       | orders     | DELETE
     test-user       | orders     | UPDATE
     test-user       | orders     | SELECT
     test-user       | orders     | INSERT
    (22 rows)
    ```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
    ```
    test-db=# SELECT * FROM orders;
     id |     наименование     | цена 
    ----+----------------------+------
      1 | Шоколад              |   10
      2 | Принтер              | 3000
      3 | Книга                |  500
      4 | Монитор              | 7000
      5 | Гитара               | 4000
    (5 rows)
    
    test-db=# SELECT count(1) FROM orders;
     count 
    -------
         5
    (1 row)
    
    test-db=# SELECT * FROM clients;
     id |       фамилия        |  страна проживания   | заказ 
    ----+----------------------+----------------------+-------
      4 | Ронни Джеймс Дио     | Russia               |      
      5 | Ritchie Blackmore    | Russia               |      
      1 | Иванов Иван Иванович | USA                  |     3
      2 | Петров Петр Петрович | Canada               |     4
      3 | Иоганн Себастьян Бах | Japan                |     5
    (5 rows)
    
    test-db=# SELECT count(1) FROM clients;
     count 
    -------
         5
    (1 row)
    ```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказка - используйте директиву `UPDATE`.
```
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Книга') WHERE "фамилия"='Иванов Иван Иванович';

UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Монитор') WHERE "фамилия"='Петров Петр Петрович';

UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Гитара') WHERE "фамилия"='Иоганн Себастьян Бах';

test-db=# SELECT c.* FROM clients c JOIN orders o ON c.заказ = o.id;
 id |       фамилия        |  страна проживания   | заказ 
----+----------------------+----------------------+-------
  1 | Иванов Иван Иванович | USA                  |     3
  2 | Петров Петр Петрович | Canada               |     4
  3 | Иоганн Себастьян Бах | Japan                |     5
(3 rows)
```
## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```
test-db=# EXPLAIN SELECT c.* FROM clients c JOIN orders o ON c.заказ = o.id;
                              QUERY PLAN                               
-----------------------------------------------------------------------
 Hash Join  (cost=25.30..40.36 rows=400 width=176)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..14.00 rows=400 width=176)
   ->  Hash  (cost=16.80..16.80 rows=680 width=4)
         ->  Seq Scan on orders o  (cost=0.00..16.80 rows=680 width=4)
(5 rows)
```
* Выполняя любой полученный запрос, Postgres Pro разрабатывает для него план запроса. 
  Выбор правильного плана, соответствующего структуре запроса и характеристикам данным, крайне важен для хорошей производительности, 
  поэтому в системе работает сложный планировщик, задача которого — подобрать хороший план. 
  Узнать, какой план был выбран для какого-либо запроса, можно с помощью команды EXPLAIN.
  
1. Прочитана таблица orders, определены стоимость запуска, общая стоимость, ожидаемое число строк, ожидаемый средний размер строк.
2. Содан хэш id для таблицы orders
3. Прочитана таблица clients, определены стоимость запуска, общая стоимость, ожидаемое число строк, ожидаемый средний размер строк.
4. Проверка строки по полю "заказ" на соответствие в кеше orders
    - false - строка будет пропущена
    - true - на основе этой строки сформируется вывод
## Задача 6

Создайте бэкап БД test-db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test-db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```
boliwar@netology:~/[06-02]$ sudo docker-compose -f docker-compose.yml up -d
boliwar@netology:~/[06-02]$ sudo docker exec -it postgres14 /bin/bash

root@16f79411eff7:/# pg_dump test-db -h localhost -U test-admin-user | gzip > /media/postgresql/backup/test-db.gz
root@16f79411eff7:/# exit

boliwar@netology:~/[06-02]$ sudo docker kill $(sudo docker ps -a -q)
16f79411eff7
boliwar@netology:~/[06-02]$ sudo docker rm $(sudo docker ps -a -q)
16f79411eff7
boliwar@netology:~/[06-02]$ sudo rm -rf db-data
boliwar@netology:~/[06-02]$ sudo docker-compose -f docker-compose.yml up -d
[+] Running 1/1
 ⠿ Container postgres14  Started              
boliwar@netology:~/[06-02]$ sudo docker exec -it postgres14 /bin/bash

root@66c23eeb9bc5:/# gunzip /media/postgresql/backup/test-db.gz | psql -h localhost -U test-admin-user -f /media/postgresql/backup/test-db test-db
root@66c23eeb9bc5:/# psql -h localhost -U test-admin-user test-db
psql (14.4 (Debian 14.4-1.pgdg110+1))
Type "help" for help.

test-db=# SELECT * FROM orders;
 id |     наименование     | цена 
----+----------------------+------
  1 | Шоколад              |   10
  2 | Принтер              | 3000
  3 | Книга                |  500
  4 | Монитор              | 7000
  5 | Гитара               | 4000
(5 rows)
```
