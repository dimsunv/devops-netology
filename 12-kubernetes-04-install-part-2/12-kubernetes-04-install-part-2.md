# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

**Answer**

<details>
<summary> hosts.yaml </summary>

```YAML
---
all:
  hosts:
    node-1:
      ansible_host: 158.160.61.6
    node-2:
      ansible_host: 158.160.62.46
    node-3:
      ansible_host: 158.160.61.195
    node-4:
      ansible_host: 158.160.43.248
    node-5:
      ansible_host: 158.160.48.44
  children:
    kube_control_plane:
      hosts:
        node-1:
    kube_node:
      hosts:
        node-1:
        node-2:
        node-3:
        node-4:
        node-5:
    etcd:
      hosts:
        node-1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
</details>

<details>
<summary> addons.yml </summary>

```YAML
---
# Kubernetes dashboard
# RBAC required. see docs/getting-started.md for access details.
dashboard_enabled: true

# Helm deployment
helm_enabled: false

# Registry deployment
registry_enabled: false
# registry_namespace: kube-system
# registry_storage_class: ""
# registry_disk_size: "10Gi"

# Metrics Server deployment
metrics_server_enabled: true
# metrics_server_container_port: 4443
# metrics_server_kubelet_insecure_tls: true
# metrics_server_metric_resolution: 15s
# metrics_server_kubelet_preferred_address_types: "InternalIP,ExternalIP,Hostname"
# metrics_server_host_network: false
# metrics_server_replicas: 1

# Rancher Local Path Provisioner
local_path_provisioner_enabled: false
# local_path_provisioner_namespace: "local-path-storage"
# local_path_provisioner_storage_class: "local-path"
# local_path_provisioner_reclaim_policy: Delete
# local_path_provisioner_claim_root: /opt/local-path-provisioner/
# local_path_provisioner_debug: false
# local_path_provisioner_image_repo: "rancher/local-path-provisioner"
# local_path_provisioner_image_tag: "v0.0.22"
# local_path_provisioner_helper_image_repo: "busybox"
# local_path_provisioner_helper_image_tag: "latest"

# Local volume provisioner deployment
local_volume_provisioner_enabled: false
# local_volume_provisioner_namespace: kube-system
# local_volume_provisioner_nodelabels:
#   - kubernetes.io/hostname
#   - topology.kubernetes.io/region
#   - topology.kubernetes.io/zone
# local_volume_provisioner_storage_classes:
#   local-storage:
#     host_dir: /mnt/disks
#     mount_dir: /mnt/disks
#     volume_mode: Filesystem
#     fs_type: ext4
#   fast-disks:
#     host_dir: /mnt/fast-disks
#     mount_dir: /mnt/fast-disks
#     block_cleaner_command:
#       - "/scripts/shred.sh"
#       - "2"
#     volume_mode: Filesystem
#     fs_type: ext4
# local_volume_provisioner_tolerations:
#   - effect: NoSchedule
#     operator: Exists

# CSI Volume Snapshot Controller deployment, set this to true if your CSI is able to manage snapshots
# currently, setting cinder_csi_enabled=true would automatically enable the snapshot controller
# Longhorn is an extenal CSI that would also require setting this to true but it is not included in kubespray
# csi_snapshot_controller_enabled: false
# csi snapshot namespace
# snapshot_controller_namespace: kube-system

# CephFS provisioner deployment
cephfs_provisioner_enabled: false
# cephfs_provisioner_namespace: "cephfs-provisioner"
# cephfs_provisioner_cluster: ceph
# cephfs_provisioner_monitors: "172.24.0.1:6789,172.24.0.2:6789,172.24.0.3:6789"
# cephfs_provisioner_admin_id: admin
# cephfs_provisioner_secret: secret
# cephfs_provisioner_storage_class: cephfs
# cephfs_provisioner_reclaim_policy: Delete
# cephfs_provisioner_claim_root: /volumes
# cephfs_provisioner_deterministic_names: true

# RBD provisioner deployment
rbd_provisioner_enabled: false
# rbd_provisioner_namespace: rbd-provisioner
# rbd_provisioner_replicas: 2
# rbd_provisioner_monitors: "172.24.0.1:6789,172.24.0.2:6789,172.24.0.3:6789"
# rbd_provisioner_pool: kube
# rbd_provisioner_admin_id: admin
# rbd_provisioner_secret_name: ceph-secret-admin
# rbd_provisioner_secret: ceph-key-admin
# rbd_provisioner_user_id: kube
# rbd_provisioner_user_secret_name: ceph-secret-user
# rbd_provisioner_user_secret: ceph-key-user
# rbd_provisioner_user_secret_namespace: rbd-provisioner
# rbd_provisioner_fs_type: ext4
# rbd_provisioner_image_format: "2"
# rbd_provisioner_image_features: layering
# rbd_provisioner_storage_class: rbd
# rbd_provisioner_reclaim_policy: Delete

# Nginx ingress controller deployment
ingress_nginx_enabled: false
# ingress_nginx_host_network: false
ingress_publish_status_address: ""
# ingress_nginx_nodeselector:
#   kubernetes.io/os: "linux"
# ingress_nginx_tolerations:
#   - key: "node-role.kubernetes.io/master"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
#   - key: "node-role.kubernetes.io/control-plane"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
# ingress_nginx_namespace: "ingress-nginx"
# ingress_nginx_insecure_port: 80
# ingress_nginx_secure_port: 443
# ingress_nginx_configmap:
#   map-hash-bucket-size: "128"
#   ssl-protocols: "TLSv1.2 TLSv1.3"
# ingress_nginx_configmap_tcp_services:
#   9000: "default/example-go:8080"
# ingress_nginx_configmap_udp_services:
#   53: "kube-system/coredns:53"
# ingress_nginx_extra_args:
#   - --default-ssl-certificate=default/foo-tls
# ingress_nginx_termination_grace_period_seconds: 300
# ingress_nginx_class: nginx

# ALB ingress controller deployment
ingress_alb_enabled: false
# alb_ingress_aws_region: "us-east-1"
# alb_ingress_restrict_scheme: "false"
# Enables logging on all outbound requests sent to the AWS API.
# If logging is desired, set to true.
# alb_ingress_aws_debug: "false"

# Cert manager deployment
cert_manager_enabled: false
# cert_manager_namespace: "cert-manager"
# cert_manager_tolerations:
#   - key: node-role.kubernetes.io/master
#     effect: NoSchedule
#   - key: node-role.kubernetes.io/control-plane
#     effect: NoSchedule
# cert_manager_affinity:
#  nodeAffinity:
#    preferredDuringSchedulingIgnoredDuringExecution:
#    - weight: 100
#      preference:
#        matchExpressions:
#        - key: node-role.kubernetes.io/control-plane
#          operator: In
#          values:
#          - ""
# cert_manager_nodeselector:
#   kubernetes.io/os: "linux"

# cert_manager_trusted_internal_ca: |
#   -----BEGIN CERTIFICATE-----
#   [REPLACE with your CA certificate]
#   -----END CERTIFICATE-----
# cert_manager_leader_election_namespace: kube-system

# cert_manager_dns_policy: "ClusterFirst"
# cert_manager_dns_config:
#   nameservers:
#     - "1.1.1.1"
#     - "8.8.8.8"

# MetalLB deployment
metallb_enabled: false
metallb_speaker_enabled: "{{ metallb_enabled }}"
# metallb_ip_range:
#   - "10.5.0.50-10.5.0.99"
# metallb_pool_name: "loadbalanced"
# metallb_auto_assign: true
# metallb_avoid_buggy_ips: false
# metallb_speaker_nodeselector:
#   kubernetes.io/os: "linux"
# metallb_controller_nodeselector:
#   kubernetes.io/os: "linux"
# metallb_speaker_tolerations:
#   - key: "node-role.kubernetes.io/master"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
#   - key: "node-role.kubernetes.io/control-plane"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
# metallb_controller_tolerations:
#   - key: "node-role.kubernetes.io/master"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
#   - key: "node-role.kubernetes.io/control-plane"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
# metallb_version: v0.12.1
# metallb_protocol: "layer2"
# metallb_port: "7472"
# metallb_memberlist_port: "7946"
# metallb_additional_address_pools:
#   kube_service_pool:
#     ip_range:
#       - "10.5.1.50-10.5.1.99"
#     protocol: "layer2"
#     auto_assign: false
#     avoid_buggy_ips: false
# metallb_protocol: "bgp"
# metallb_peers:
#   - peer_address: 192.0.2.1
#     peer_asn: 64512
#     my_asn: 4200000000
#   - peer_address: 192.0.2.2
#     peer_asn: 64513
#     my_asn: 4200000000

argocd_enabled: false
# argocd_version: v2.5.10
# argocd_namespace: argocd
# Default password:
#   - https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli
#   ---
#   The initial password is autogenerated to be the pod name of the Argo CD API server. This can be retrieved with the command:
#   kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
#   ---
# Use the following var to set admin password
# argocd_admin_password: "password"

# The plugin manager for kubectl
krew_enabled: false
krew_root_dir: "/usr/local/krew"
```

</details>


## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

---

**Answer**

- Для задания используется Яндекс Облако. Для разворачивания инфраструктуры Terraform. Для установки кластера Kubernetes - kubespray.
- Файл инвентори `hosts.yaml` формируется динамиченски в зависимости от инстансев указанных в `terraform/main.tf`.
- Файл метаданных для инстансов `meta.yml` необходим для указания пользователя и ключей при создании инстансов яндекс-облаком(по умолчанию будет создан пользователь yc_user). Путь указать в `modules/instanse/instanse.tf`
```
#cloud-config
users:
  - name: boliwar
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - "ssh-rsa ......hcxyUSuEv1xM= boliwar@netology"
```

- Путь указать в `modules/instanse/instanse.tf`
```
metadata = {
    user-data = "${file("/home/boliwar/meta.yml")}"
  }
```
- Переменные `terraform/variables.tf`:
    * `yc_token`
    * `yc_cloud_id`
    * `yc_folder_id`
    * `yc_region`
    * `kubespray_config_path`

```
terraform init
terraform workspace new kube
terraform plan
terraform apply --auto-approve

ssh <IP>
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown  $(id -u):$(id -g) ~/.kube/config
[boliwar@node-1 ~]$ kubectl get nodes
NAME     STATUS   ROLES           AGE    VERSION
node-1   Ready    control-plane   179m   v1.26.1
node-2   Ready    <none>          177m   v1.26.1
node-3   Ready    <none>          177m   v1.26.1
node-4   Ready    <none>          177m   v1.26.1
node-5   Ready    <none>          177m   v1.26.1
```

[terraform resources](https://github.com/dimsunv/devops-netology/tree/12-kubernetes-04-install-part-2)