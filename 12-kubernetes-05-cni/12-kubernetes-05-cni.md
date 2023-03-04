# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

**Answer**

- Для установки используется `kubespray` + `terraform` . Исходники для базового кластера тут - [terraform resources](https://github.com/dimsunv/devops-netology/tree/12-kubernetes-04-install-part-2)


<details>
<summary> hello-world.yml </summary>

```YML
---
apiVersion: v1
kind: Namespace
metadata:
  name: homework

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello-world
  name: hello-world
  namespace: homework
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: echoserver
        image: k8s.gcr.io/echoserver:1.4
        imagePullPolicy: IfNotPresent
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-world
  name: hello-world
  namespace: homework
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: hello-world
  type: ClusterIP
```

</details>

---

```
yc compute instance list --folder-id b1g8qdvisd0c3v836k0u
+----------------------+--------+---------------+---------+----------------+-------------+
|          ID          |  NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+--------+---------------+---------+----------------+-------------+
| fhm8utd1uqut91cfqnoo | node-2 | ru-central1-a | RUNNING | 158.160.35.244 | 10.130.0.35 |
| fhmbka1j663i5hkstbhb | node-1 | ru-central1-a | RUNNING | 158.160.53.139 | 10.130.0.7  |
| fhmovke9gmc3gtr9nisj | node-3 | ru-central1-a | RUNNING | 84.201.135.155 | 10.130.0.34 |
+----------------------+--------+---------------+---------+----------------+-------------+
```
```
kubectl get nodes -o wide
NAME     STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE          KERNEL-VERSION          CONTAINER-RUNTIME
node-1   Ready    control-plane   2d8h   v1.26.1   10.130.0.7    <none>        CentOS Stream 8   4.18.0-408.el8.x86_64   containerd://1.6.18
node-2   Ready    <none>          2d8h   v1.26.1   10.130.0.35   <none>        CentOS Stream 8   4.18.0-408.el8.x86_64   containerd://1.6.18
node-3   Ready    <none>          2d8h   v1.26.1   10.130.0.34   <none>        CentOS Stream 8   4.18.0-408.el8.x86_64   containerd://1.6.18
```
```
kubectl apply -f hello-world.yml
namespace/hello-world created
deployment.apps/hello-world created
service/hello-world created
```
```
kubectl -n homework get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE    IP             NODE     NOMINATED NODE   READINESS GATES
hello-world-9b5c8666-4bhx4   1/1     Running   0          3m5s   10.233.65.66   node-2   <none>           <none>
hello-world-9b5c8666-njq5m   1/1     Running   0          3m5s   10.233.75.67   node-3   <none>           <none>
```
```
kubectl -n homework get service -o wide
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE     SELECTOR
hello-world   ClusterIP   10.233.47.89   <none>        80/TCP   3m27s   app=hello-world
```
```
kubectl -n homework get deploy -o wide
NAME          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                      SELECTOR
hello-world   2/2     2            2           4m34s   echoserver   k8s.gcr.io/echoserver:1.4   app=hello-world
```
```
kubectl get ep -n homework
NAME          ENDPOINTS                             AGE
hello-world   10.233.65.66:8080,10.233.75.67:8080   5m57s
```
```
kubectl apply -f ingress.yml 
ingress.networking.k8s.io/hello-world created
```

- Доступ из сети Интернет по внешнему IP Yandex Cloud
  * Добавим в `/etc/hosts` внешний IP YC и присвоим ему доменное имя `homework.netology`

```
boliwar@netology:~/devops-netology/12-kubernetes-05-cni$ curl http://homework.netology
CLIENT VALUES:
client_address=10.233.70.64
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://homework.netology:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=homework.netology
user-agent=curl/7.81.0
x-forwarded-for=178.32.196.9
x-forwarded-host=homework.netology
x-forwarded-port=80
x-forwarded-proto=http
x-forwarded-scheme=http
x-real-ip=178.32.196.9
x-request-id=87db8bd57b8ad132264de8eea1178679
x-scheme=http
BODY:
-no body in request-
```

### Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список nodes, ipPool и profiles.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

**Answer**

- Install calicoctl

```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calicoctl.yaml
serviceaccount/calicoctl created
pod/calicoctl created
clusterrole.rbac.authorization.k8s.io/calicoctl created
clusterrolebinding.rbac.authorization.k8s.io/calicoctl created
```
```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl --allow-version-mismatch get nodes -o wide
NAME     ASN       IPV4             IPV6   
node-1   (64512)   10.130.0.7/24           
node-2   (64512)   10.130.0.35/24          
node-3   (64512)   10.130.0.34/24    
```

```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl --allow-version-mismatch get ipPool -o wide
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR   
default-pool   10.233.64.0/18   true   Never      Always      false      false              all() 
```

```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl --allow-version-mismatch get profiles -o wide
NAME                                                 LABELS                                                                                                                             
projectcalico-default-allow                                                                                                                                                             
kns.default                                          pcns.kubernetes.io/metadata.name=default,pcns.projectcalico.org/name=default                                                       
kns.homework                                         pcns.kubernetes.io/metadata.name=homework,pcns.projectcalico.org/name=homework                                                     
kns.ingress-nginx                                    pcns.kubernetes.io/metadata.name=ingress-nginx,pcns.name=ingress-nginx,pcns.projectcalico.org/name=ingress-nginx                   
kns.kube-node-lease                                  pcns.kubernetes.io/metadata.name=kube-node-lease,pcns.projectcalico.org/name=kube-node-lease                                       
kns.kube-public                                      pcns.kubernetes.io/metadata.name=kube-public,pcns.projectcalico.org/name=kube-public                                               
kns.kube-system                                      pcns.kubernetes.io/metadata.name=kube-system,pcns.projectcalico.org/name=kube-system                                               
ksa.default.default                                  pcsa.projectcalico.org/name=default                                                                                                
ksa.homework.default                                 pcsa.projectcalico.org/name=default                                                                                                
ksa.ingress-nginx.default                            pcsa.projectcalico.org/name=default                                                                                                
ksa.ingress-nginx.ingress-nginx                      pcsa.app.kubernetes.io/name=ingress-nginx,pcsa.app.kubernetes.io/part-of=ingress-nginx,pcsa.projectcalico.org/name=ingress-nginx   
ksa.kube-node-lease.default                          pcsa.projectcalico.org/name=default                                                                                                
ksa.kube-public.default                              pcsa.projectcalico.org/name=default                                                                                                
ksa.kube-system.attachdetach-controller              pcsa.projectcalico.org/name=attachdetach-controller                                                                                
ksa.kube-system.bootstrap-signer                     pcsa.projectcalico.org/name=bootstrap-signer                                                                                       
ksa.kube-system.calico-kube-controllers              pcsa.projectcalico.org/name=calico-kube-controllers                                                                                
ksa.kube-system.calico-node                          pcsa.projectcalico.org/name=calico-node                                                                                            
ksa.kube-system.calicoctl                            pcsa.projectcalico.org/name=calicoctl                                                                                              
ksa.kube-system.certificate-controller               pcsa.projectcalico.org/name=certificate-controller                                                                                 
ksa.kube-system.clusterrole-aggregation-controller   pcsa.projectcalico.org/name=clusterrole-aggregation-controller                                                                     
ksa.kube-system.coredns                              pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=coredns                                                 
ksa.kube-system.cronjob-controller                   pcsa.projectcalico.org/name=cronjob-controller                                                                                     
ksa.kube-system.daemon-set-controller                pcsa.projectcalico.org/name=daemon-set-controller                                                                                  
ksa.kube-system.default                              pcsa.projectcalico.org/name=default                                                                                                
ksa.kube-system.deployment-controller                pcsa.projectcalico.org/name=deployment-controller                                                                                  
ksa.kube-system.disruption-controller                pcsa.projectcalico.org/name=disruption-controller                                                                                  
ksa.kube-system.dns-autoscaler                       pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=dns-autoscaler                                          
ksa.kube-system.endpoint-controller                  pcsa.projectcalico.org/name=endpoint-controller                                                                                    
ksa.kube-system.endpointslice-controller             pcsa.projectcalico.org/name=endpointslice-controller                                                                               
ksa.kube-system.endpointslicemirroring-controller    pcsa.projectcalico.org/name=endpointslicemirroring-controller                                                                      
ksa.kube-system.ephemeral-volume-controller          pcsa.projectcalico.org/name=ephemeral-volume-controller                                                                            
ksa.kube-system.expand-controller                    pcsa.projectcalico.org/name=expand-controller                                                                                      
ksa.kube-system.generic-garbage-collector            pcsa.projectcalico.org/name=generic-garbage-collector                                                                              
ksa.kube-system.horizontal-pod-autoscaler            pcsa.projectcalico.org/name=horizontal-pod-autoscaler                                                                              
ksa.kube-system.job-controller                       pcsa.projectcalico.org/name=job-controller                                                                                         
ksa.kube-system.kube-proxy                           pcsa.projectcalico.org/name=kube-proxy                                                                                             
ksa.kube-system.namespace-controller                 pcsa.projectcalico.org/name=namespace-controller                                                                                   
ksa.kube-system.node-controller                      pcsa.projectcalico.org/name=node-controller                                                                                        
ksa.kube-system.nodelocaldns                         pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=nodelocaldns                                            
ksa.kube-system.persistent-volume-binder             pcsa.projectcalico.org/name=persistent-volume-binder                                                                               
ksa.kube-system.pod-garbage-collector                pcsa.projectcalico.org/name=pod-garbage-collector                                                                                  
ksa.kube-system.pv-protection-controller             pcsa.projectcalico.org/name=pv-protection-controller                                                                               
ksa.kube-system.pvc-protection-controller            pcsa.projectcalico.org/name=pvc-protection-controller                                                                              
ksa.kube-system.replicaset-controller                pcsa.projectcalico.org/name=replicaset-controller                                                                                  
ksa.kube-system.replication-controller               pcsa.projectcalico.org/name=replication-controller                                                                                 
ksa.kube-system.resourcequota-controller             pcsa.projectcalico.org/name=resourcequota-controller                                                                               
ksa.kube-system.root-ca-cert-publisher               pcsa.projectcalico.org/name=root-ca-cert-publisher                                                                                 
ksa.kube-system.service-account-controller           pcsa.projectcalico.org/name=service-account-controller                                                                             
ksa.kube-system.service-controller                   pcsa.projectcalico.org/name=service-controller                                                                                     
ksa.kube-system.statefulset-controller               pcsa.projectcalico.org/name=statefulset-controller                                                                                 
ksa.kube-system.token-cleaner                        pcsa.projectcalico.org/name=token-cleaner                                                                                          
ksa.kube-system.ttl-after-finished-controller        pcsa.projectcalico.org/name=ttl-after-finished-controller                                                                          
ksa.kube-system.ttl-controller                       pcsa.projectcalico.org/name=ttl-controller
```