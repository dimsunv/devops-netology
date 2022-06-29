# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

```
root@docker:~# cat > /home/serafim/index.html <<EOF
> <html>
> <head>
> Hey, Netology
> </head>
> <body>
> <h1>I’m DevOps Engineer!</h1>
> </body>
> </html>
> EOF
root@docker:~# docker run --name nginx_netology -p 80:80 -d nginx
root@docker:~# docker cp /home/serafim/index.html nginx_netology:/usr/share/nginx/html
root@docker:~# curl localhost:80
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I'm DevOps Engineer!</h1>
</body>
</html>
root@docker:~# docker commit nginx_netology boliwar/nginx_netology
root@docker:~# docker push boliwar/nginx_netology
```
* Ссылка на репозиторий:
[Docker hub](https://hub.docker.com/repository/docker/boliwar/nginx_netology)
## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
  * Высоконагруженные приложения предпочтительно размещать на физических машинах или ВМ. Необходим оперативный доступ к ресурсам.
- Nodejs веб-приложение;
  * Dоcker вполне подойдет для легких серверных приложений.
- Мобильное приложение c версиями для Android и iOS;
  * Физическое устройство с ОС Android или iOS
- Шина данных на базе Apache Kafka;
  * Физические или виртуальные машины. Брокер использует и обрабатывает данные складывая их на диск. Для тестовых запусков подойдет и Docker.
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
  * Elasticsearvh лучше на виртуальной машине, kibana и logstash можно развернуть в Docker.
- Мониторинг-стек на базе Prometheus и Grafana;
  * Docker. Сбор метрик и их представление в виде web приложения не требуют оперативного доступа к ресурсам.
- MongoDB, как основное хранилище данных для java-приложения;
  * Базы данных желательно размещать на физических машинах или виртуальных.
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
  * Виртуальные машины для репозиториев, docker для сервисов.
## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```
root@docker:~# docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
f087646a20af2bb1069e1fb66cd6999f1a7bd4a94c5903421d4e2fc2643cd2da
root@docker:~# docker run -it --rm -d --name debian -v $(pwd)/data:/data debian:latest
214faf9871d5a4cc2fd27defe078932e539f2157f7a43ed0fe2135dc6d8ce012
root@docker:~# docker ps
CONTAINER ID   IMAGE           COMMAND       CREATED              STATUS              PORTS     NAMES
214faf9871d5   debian:latest   "bash"        22 seconds ago       Up 19 seconds                 debian
f087646a20af   centos:latest   "/bin/bash"   About a minute ago   Up About a minute             centos
root@docker:~# cat /etc/*release >> data/host.txt
root@docker:~# docker exec -it debian bash
root@214faf9871d5:/# ls data
centos.txt  host.txt
```
## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

* Dockerfile
```
FROM debian

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install ansible -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
```
```
root@docker:~/myproject# docker run boliwar/ansible_netology:2.10.8
ansible-playbook 2.10.8
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```
*Ссылка на репозиторий:
[Docker hub](https://hub.docker.com/repository/docker/boliwar/ansible_netology)