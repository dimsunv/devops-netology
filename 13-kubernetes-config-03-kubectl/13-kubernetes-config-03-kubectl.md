# Домашнее задание к занятию "13.3 работа с kubectl"

## Задание 1: проверить работоспособность каждого компонента

Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:

* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

***Answer***

```SHELL
kubectl config set-context --current --namespace=prod
kubectl get po
    NAME                                  READY   STATUS    RESTARTS   AGE
    backend-6774448c45-lhcn7              1/1     Running   0          37m
    frontend-85d47b87f6-mmkgk             1/1     Running   0          37m
    nfs-server-nfs-server-provisioner-0   1/1     Running   0          30m
    postgres-0                            1/1     Running   0          37m
```

```SHELL
kubectl exec -it frontend-85d47b87f6-mmkgk /bin/sh
# ls -la
total 20
drwxr-xr-x. 1 root root   23 Mar 12 18:58 .
drwxr-xr-x. 1 root root   53 Mar 24 21:37 ..
-rw-rw-r--. 1 root root  448 Mar 10 10:24 index.html
-rw-rw-r--. 1 root root  344 Mar 10 10:24 item.html
-rw-rw-r--. 1 root root   80 Mar 10 10:24 list.json
-rw-r--r--. 1 root root 2515 Mar 12 18:58 main.css
-rw-r--r--. 1 root root 3231 Mar 12 18:58 main.js
```

```SHELL
kubectl port-forward pod/backend-6774448c45-lhcn7  :9000
    Forwarding from 127.0.0.1:40623 -> 9000
    Forwarding from [::1]:40623 -> 9000
curl http://localhost:40623/startup
    {"detail":"Not Found"}
```

```SHELL
kubectl port-forward pod/frontend-85d47b87f6-mmkgk  :80
    Forwarding from 127.0.0.1:41521 -> 80
    Forwarding from [::1]:41521 -> 80

curl http://localhost:41521
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <title>Список</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="/build/main.css" rel="stylesheet">
    </head>
    <body>
        <main class="b-page">
            <h1 class="b-page__title">Список</h1>
            <div class="b-page__content b-items js-list"></div>
        </main>
        <script src="/build/main.js"></script>
    </body>
```

```SHELL
kubectl port-forward pod/postgres-0 :5432
    Forwarding from 127.0.0.1:32967 -> 5432
    Forwarding from [::1]:32967 -> 5432

psql -U postgres -d news -h localhost -p 32967
    psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1), server 13.10)
    Type "help" for help.

    news=# \l
                                    List of databases
    Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
    -----------+----------+----------+------------+------------+-----------------------
    news      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
    postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
    template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
            |          |          |            |            | postgres=CTc/postgres
    template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
            |          |          |            |            | postgres=CTc/postgres
    (4 rows)
```



## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

***Answer***

```SHELL
kubectl get pods -o wide
    NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
    backend-6774448c45-lhcn7              1/1     Running   0          40m   10.233.65.68   node-2   <none>           <none>
    frontend-85d47b87f6-mmkgk             1/1     Running   0          40m   10.233.75.69   node-3   <none>           <none>
    nfs-server-nfs-server-provisioner-0   1/1     Running   0          34m   10.233.65.67   node-2   <none>           <none>
    postgres-0                            1/1     Running   0          40m   10.233.75.68   node-3   <none>           <none>
```

```SHELL
kubectl scale --replicas=3 deploy/backend
    deployment.apps/backend scaled
kubectl scale --replicas=3 deploy/frontend
    deployment.apps/frontend scaled
kubectl get pods -o wide
    NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
    backend-6774448c45-k7rsh              1/1     Running   0          86s   10.233.70.67   node-1   <none>           <none>
    backend-6774448c45-lhcn7              1/1     Running   0          44m   10.233.65.68   node-2   <none>           <none>
    backend-6774448c45-xjwnp              1/1     Running   0          86s   10.233.75.70   node-3   <none>           <none>
    frontend-85d47b87f6-68wbg             1/1     Running   0          75s   10.233.70.68   node-1   <none>           <none>
    frontend-85d47b87f6-mmkgk             1/1     Running   0          44m   10.233.75.69   node-3   <none>           <none>
    frontend-85d47b87f6-p4tq9             1/1     Running   0          75s   10.233.65.69   node-2   <none>           <none>
    nfs-server-nfs-server-provisioner-0   1/1     Running   0          38m   10.233.65.67   node-2   <none>           <none>
    postgres-0                            1/1     Running   0          44m   10.233.75.68   node-3   <none>           <none>
kubectl get pods -o wide
    NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
    backend-6774448c45-lhcn7              1/1     Running   0          46m   10.233.65.68   node-2   <none>           <none>
    frontend-85d47b87f6-mmkgk             1/1     Running   0          46m   10.233.75.69   node-3   <none>           <none>
    nfs-server-nfs-server-provisioner-0   1/1     Running   0          39m   10.233.65.67   node-2   <none>           <none>
    postgres-0                            1/1     Running   0          46m   10.233.75.68   node-3   <none>           <none>
```

---
