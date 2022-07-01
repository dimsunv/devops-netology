###Pritunl
```
pritunl-client add 
pritunl-client list
pritunl-client start
pritunl-client stop
pritunl-client remove
# поверить внешний ip
wget -qO- eth0.me
curl ifconfig.co
```
###YC
```

```

* Создайте авторизованные ключи для сервисного аккаунта dimsun:
```
yc iam key create --service-account-name dimsun -o key.json
```
Создать сеть
```
yc vpc network create --name net --labels my-label=netology --description "my test network"
```
Создать подсеть
```
yc vpc subnet create --name subnet-a --zone ru-central1-a --range 172.16.10.0/24 --network-name net --description "my test subnet"
```
Удалить подсеть и сеть
```
yc vpc subnet delete --name subnet-a && yc vpc network delete --name net
```
###Packer
```
packer build ./src/packer/centos-7-base.json
```
###Terraform
```
terraform plan
```
```
terraform apply -auto-approve
```
```
terraform destroy -auto-approve
```
###Ansible
ansible-playbook provision.yml

