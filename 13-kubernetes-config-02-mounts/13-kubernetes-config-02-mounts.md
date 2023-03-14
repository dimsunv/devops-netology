# Домашнее задание к занятию "13.2 разделы и монтирование"

Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):

* установить helm: curl <https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3> | bash
* добавить репозиторий чартов: helm repo add stable <https://charts.helm.sh/stable> && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

```SHELL
kubectl get sc
    NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
    nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   72m
```

## Задание 1: подключить для тестового конфига общую папку

В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:

* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

<details>
<summary> deployment.yml </summary>

```YAML
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: news
  name: news
  namespace: stage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: news
  template:
    metadata:
      labels:
        app: news
    spec:
      containers:
        - image: boliwar/backend:latest
          name: backend
          env:
            - name: DATABASE_URL
              value: postgresql://postgres:postgres@postgres:5432/news
          ports:
            - containerPort: 9000
          volumeMounts:
            - mountPath: "/mp/cache"
              name: my-volume
          resources:
            limits:
              cpu: 200m
              memory: 256Mi
            requests:
              cpu: 100m
              memory: 128Mi
        
        - image: boliwar/frontend:latest
          name: frontend
          ports:
            - containerPort: 80
          env:
            - name: BASE_URL
              value: http://news:9000
          volumeMounts:
            - mountPath: "/static"
              name: my-volume
          resources:
            limits:
              cpu: 200m
              memory: 256Mi
            requests:
              cpu: 100m
              memory: 128Mi
      volumes:
        - name: my-volume
          emptyDir: {}
```

</details>

## Задание 2: подключить общую папку для прода

Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:

* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

```SHELL
kubectl exec -it frontend-85d47b87f6-c5nx7 -n prod /bin/sh
df -h
Filesystem                                                      Size  Used Avail Use% Mounted on
overlay                                                          50G  5.6G   45G  12% /
tmpfs                                                            64M     0   64M   0% /dev
tmpfs                                                           1.9G     0  1.9G   0% /sys/fs/cgroup
10.233.16.190:/export/pvc-f51a804e-4dcd-4b0f-adb8-ecf7be6cb710   50G  6.2G   44G  13% /static
/dev/vda2                                                        50G  5.6G   45G  12% /etc/hosts
shm                                                              64M     0   64M   0% /dev/shm
tmpfs                                                           256M   12K  256M   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                                                           1.9G     0  1.9G   0% /proc/acpi
tmpfs                                                           1.9G     0  1.9G   0% /proc/scsi
tmpfs                                                           1.9G     0  1.9G   0% /sys/firmware
```

---

[Исходники](https://github.com/dimsunv/devops-netology/tree/13-kubernetes-config-02-mounts)
