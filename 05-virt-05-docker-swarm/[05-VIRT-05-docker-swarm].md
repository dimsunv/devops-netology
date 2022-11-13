# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
    * В режиме replicated приложение запускается в том количестве экземпляров, какое укажет пользователь. При этом на отдельной
      ноде может быть как несколько экземпляров приложения, так и не быть совсем.
      В режиме global приложение запускается обязательно на каждой ноде и в единственном экземпляре.

- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
    *  Алгоритм поддержания распределенного консенсуса — Raft.
- Что такое Overlay Network?
    * Overlay-сети используются в контексте кластеров (Docker Swarm), где виртуальная сеть, которую используют контейнеры,
      связывает несколько физических хостов, на которых запущен Docker.
      Overlay-сеть создает подсеть, которую могут использовать контейнеры в разных хостах swarm-кластера.
      Контейнеры на разных физических хостах могут обмениваться данными по overlay-сети.


## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```
```
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
sveardjl9p1lzmjna91kikkq3 *   node01.netology.yc   Ready     Active         Leader           20.10.17
bpqfap3uxtspu7z4vi9kra6ot     node02.netology.yc   Ready     Active         Reachable        20.10.17
b0q70tqmtqqjvf4z7ytct8lee     node03.netology.yc   Ready     Active         Reachable        20.10.17
bqctxzfwt0b7ktf59lh5e34br     node04.netology.yc   Ready     Active                          20.10.17
t17flc4pwor6siqs69q1bk8w8     node05.netology.yc   Ready     Active                          20.10.17
gp90w0kktawscwp24spf1o2kd     node06.netology.yc   Ready     Active                          20.10.17
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
```
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ac02fb8f0y20   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
l9vxa6ojtb5y   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
m0flzzzcmf5p   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
99osw7pds9d0   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
lz3bz8ui174g   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
pp3xvhgmvxau   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
7ap2sjjr8ij3   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
vmsf2vp1i4la   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```
## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```
```
[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-vJQZ8aPGbyp87476w6SVZ/iZfz0ysfX8jPKcHkUW7RE

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
* Команда --autolock=true включает режим для ввода ключа разблокировки на ноде, чтобы при перезагрузке она могла присоединиться к кластеру.
  Ввод ключа позволит расшифровать лог Raft и загрузить все "секреты" в память ноды. Необходим для защиты кластера от несанкционированного доступа и компроментации.

[source](https://github.com/dimsunv/devops-netology/tree/05-src_swarm)
