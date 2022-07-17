###Pritunl
```
sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb https://repo.pritunl.com/stable/apt focal main
EOF
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get update
sudo apt-get install pritunl-client-electron

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
Создайте авторизованные ключи для сервисного аккаунта akk:
```
yc iam key create --service-account-name akk -o key.json
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


###Ansible
```
# install ubuntu 22.04
apt install ansible
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt remove ansible
apt install ansible
```

###Docker
```
curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh
curl -L https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose
```