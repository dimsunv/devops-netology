# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2).

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

***Answer***

* Для создания deployment можно использовать терминал `kubectl create deployment hello`
```
boliwar@netology:~$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2
deployment.apps/hello created
boliwar@netology:~$ kubectl get deployment
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
hello   2/2     2            2           99s
boliwar@netology:~$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
hello-56c75d54f7-65gr6   1/1     Running   0          105s
hello-56c75d54f7-9k8gd   1/1     Running   0          105s
```
* но лучше использовать декларативный метод с помощью yaml файлов. В дальнейшем это позволит использовать контроль версий наших проектов.

<details>
<summary> deployment.yaml </summary>

```YAML
---
#deployment settings
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-node
  labels:
    app: hello-node
spec:
#replica settings
  replicas: 3
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  selector:
    matchLabels:
      app: hello-node
#pod settings
  template:
    metadata:
      labels:
        app: hello-node
    spec:
      containers:
        - name: hello-node
          image: k8s.gcr.io/echoserver:1.4
          ports:
            - containerPort: 8080
```

</details>

* Создадим deployment используя `deployment.yaml`

```
boliwar@netology:~$ kubectl apply -f deployment.yaml
deployment.apps/hello-node created

boliwar@netology:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-78bc8fbcfd-6mt7x   1/1     Running   0          11s
hello-node-78bc8fbcfd-xvhpc   1/1     Running   0          11s

boliwar@netology:~$ kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           29s
```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе.
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования:
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

**Answer***

* Для начала создадим пространство имен добавив в начало `deployment.yaml` конфигурцию namespace и пропишем namespace `app-namespace` в конфигурации `deployment` и `pod`

<details>
<summary>deployment.yaml</summary>

---
#create namespace
apiVersion: v1
kind: Namespace
metadata:
  name: app-namespace
---
#deployment settings
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: app-namespace
  name: hello-node
  labels:
    app: hello-node
spec:
#replica settings
  replicas: 2
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  selector:
    matchLabels:
      app: hello-node
#pod settings
  template:
    metadata:
      namespace: app-namespace
      labels:
        app: hello-node
    spec:
      containers:
        - name: hello-node
          image: k8s.gcr.io/echoserver:1.4
          ports:
            - containerPort: 8080

</details>

```
boliwar@netology:~$ kubectl apply -f deployment.yaml
namespace/app-namespace created
deployment.apps/hello-node created

boliwar@netology:~$ kubectl get ns
NAME                   STATUS   AGE
app-namespace          Active   57s
default                Active   162m
ingress-nginx          Active   161m
kube-node-lease        Active   162m
kube-public            Active   162m
kube-system            Active   162m
kubernetes-dashboard   Active   161m

boliwar@netology:~$ kubectl get pods -n app-namespace
NAME                         READY   STATUS    RESTARTS   AGE
hello-node-54556fd5c-r8zpg   1/1     Running   0          27s
hello-node-54556fd5c-xqvsg   1/1     Running   0          27s

boliwar@netology:~$ kubectl get deployment -n app-namespace
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           39s
```

* Добавим пользователя `developer` на наш хост:

```
root$ useradd developer -d /home/developer -m -s/bin/bash -c Developer && cd /home/developer

```

* Сгенерируем SSL сертификаты для пользователя `developer`

```
root@netology:/home/developer# openssl genrsa -out developer.key 2048
root@netology:/home/developer# openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"
root@netology:/home/developer# openssl x509 -req -in developer.csr -CA /home/boliwar/.minikube/ca.crt -CAkey /home/boliwar/.minikube/ca.key -CAcreateserial -out developer.crt -days 500
root@netology:/home/developer# mkdir .certs && mv developer.crt developer.key .certs
root@netology:/home/developer# mkdir /mimikube && cp /home/boliwar/.minikube/ca.crt /home/developer/.minikube/ca.crt
```

* Добавим пользователя в кластер:

```
boliwar@netology:~$ kubectl config set-credentials developer --client-certificate=/home/developer/.certs/developer.crt --client-key=/home/developer/.certs/developer.key
```

* И создадим для него контекст:

```
boliwar@netology:~$ kubectl config set-context developer --cluster=minikube --user=developer
```

* Создадим конфигурационный файл для аутентификации на кластер:

```
root@netology:/home/developer# mkdir .kube && nano .kube/config
```

* следующего содержания:

<details>
<summary>config</summary>

apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/boliwar/.minikube/ca.crt
    server: https://192.168.49.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: developer
  name: developer-context
current-context: developer-context
kind: Config
preferences: {}
users:
- name: developer
  user:
    client-certificate: /home/developer/.certs/developer.crt
    client-key: /home/developer/.certs/developer.key

</details>

* Предоставим права пользователю ко всем ранее созданным файлам и директориям:

```
root@netology:/home/developer# chown -R developer: /home/developer/
```

* Проверить доступ можно командой `kubectl auth can-i list pods`
  - Так выглядит ответ при старте команды от имени пользователя запустившего кластер
```
boliwar@netology:~$ kubectl auth can-i list pods
yes
boliwar@netology:~$ kubectl auth can-i list pods -n app-namespace
yes
```
  - Так от пользователя `developer`
```
boliwar@netology:~$ kubectl auth can-i list pods --as developer
no
boliwar@netology:~$ kubectl auth can-i list pods -n app-namespace --as developer
no

```

* Для доступа неоходимо создать `Role` и `RoleBinding`. Создадим файл `permits.yaml`:

<details>
<summary>permits.yaml</summary>

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: app-namespace
  name: app-log-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-log-reader-rolebinding
  namespace: app-namespace
subjects:
  - kind: User
    name: developer
roleRef:
  kind: Role
  name: app-log-reader
  apiGroup: rbac.authorization.k8s.io

</details>

```
boliwar@netology:~$ kubectl apply -f permits.yaml
role.rbac.authorization.k8s.io/app-log-reader created
rolebinding.rbac.authorization.k8s.io/app-log-reader-rolebinding created
```

* Проверяем разрешения:

```
boliwar@netology:~$ kubectl auth can-i list pods --as developer
no
boliwar@netology:~$ kubectl auth can-i list pods -n app-namespace --as developer
yes
boliwar@netology:~$ kubectl auth can-i list pods/log -n app-namespace --as developer
yes
```

## Задание 3: Изменение количества реплик
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик.

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

***Answer***

* для изменения количества реплик изменить `replicas:` в `deployment.yaml`:

```
boliwar@netology:~$ kubectl apply -f deployment.yaml
namespace/app-namespace unchanged
deployment.apps/hello-node configured
boliwar@netology:~$ kubectl get pods -n app-namespace
NAME                         READY   STATUS    RESTARTS   AGE
hello-node-54556fd5c-4l5sd   1/1     Running   0          16s
hello-node-54556fd5c-66sr6   1/1     Running   0          16s
hello-node-54556fd5c-lrgtq   1/1     Running   0          16s
hello-node-54556fd5c-r8zpg   1/1     Running   0          70m
hello-node-54556fd5c-xqvsg   1/1     Running   0          70m
```
---
