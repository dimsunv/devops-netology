# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"

Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения

Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:

* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

***Anwser***

* Add config to local pc

```SHELL
rm ~/.kube/config
ssh 158.160.40.12 sudo cat /etc/kubernetes/admin.conf >> ~/.kube/config
sed -i s%127.0.0.1%158.160.40.12% ~/.kube/config
```

* add namespace:

```SHELL
kubectl apply -f namespace.yml
    namespace/stage created
    namespace/prod created
```

* add statefulset postgres:

```SHELL
kubectl apply -f postgres.yml
    statefulset.apps/postgres created
kubectl get pods -n stage
    NAME         READY   STATUS    RESTARTS   AGE
    postgres-0   0/1     Running   0          27s
```

* add deployment frondend + backend:

```SHELL
kubectl apply -f deployment.yml
    deployment.apps/news created
kubectl get po -n stage -o wide
    NAME                    READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
    news-69f588f4db-sbfv4   2/2     Running   0          5m22s   10.233.65.73   node-2   <none>           <none>
    postgres-0              0/1     Running   0          96m     10.233.75.66   node-3   <none>           <none>
```

* add service:

```SHELL
kubectl apply -f /home/boliwar/myproject/13-kubernetes-config-01-objects/app/stage/service.yml
    service/postgres created
    service/news-frontend created
kubectl get svc -n stage -o wide
    NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE   SELECTOR
    news-frontend   NodePort    10.233.40.124   <none>        80:30080/TCP,9000:30090/TCP   62s   app=news
    postgres        ClusterIP   10.233.39.226   <none>        5432/TCP                      62s   app=postgres
```

* Check host:

```SHELL
curl http://158.160.40.12:30080
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

## Задание 2: подготовить конфиг для production окружения

Следующим шагом будет запуск приложения в production окружении. Требования сложнее:

* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

* add frondend backend postgres:

```SHELL
kubectl apply -f backend.yml -f frontend.yml -f postgres.yml 
    deployment.apps/backend created
    deployment.apps/frontend created
    statefulset.apps/postgres created
kubectl get po -n prod -o wide
    NAME                       READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
    backend-77fb4cff77-7knwp   1/1     Running   0          2m24s   10.233.75.67   node-3   <none>           <none>
    frontend-c889c9b76-fxx2z   1/1     Running   0          2m24s   10.233.75.69   node-3   <none>           <none>
    postgres-0                 1/1     Running   0          2m24s   10.233.75.68   node-3   <none>           <none>
```

* add service:

```SHELL
kubectl apply -f service.yml 
    service/postgres created
    service/backend created
    service/frontend created
kubectl get service -n prod -o wide
    NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
    backend    ClusterIP   10.233.49.153   <none>        9000/TCP   53s   app=backend
    frontend   ClusterIP   10.233.44.186   <none>        80/TCP     53s   app=frontend
    postgres   ClusterIP   10.233.40.110   <none>        5432/TCP   53s   app=postgres
```

* add ingress:

```SHELL
kubectl apply -f ingress.yml 
    ingress.networking.k8s.io/frontend created
    ingress.networking.k8s.io/backend created
kubectl get ingress -n prod -o wide
    NAME       CLASS    HOSTS               ADDRESS                              PORTS   AGE
    backend    <none>   homework.netology   10.130.0.23,10.130.0.27,10.130.0.5   80      39s
    frontend   <none>   homework.netology   10.130.0.23,10.130.0.27,10.130.0.5   80      39s
```

* Check host:

```SHELL
curl http://homework.netology
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

[Исходники](https://github.com/dimsunv/devops-netology/tree/13-kubernetes-config-01-objects)

## Задание 3 (*): добавить endpoint на внешний ресурс api

Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:

* добавлен endpoint до внешнего api (например, геокодер).

---
