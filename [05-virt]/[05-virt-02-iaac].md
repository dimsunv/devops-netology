## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.


  - Скорость работы: с ростом количества обслуживаемых хостов растет скорость работы.
  - Масштабируемость и стандартизация: IaC предоставляет стабильные среды быстро и на должном уровне. Командам разработчиков не нужно прибегать к ручной настройке - они обеспечивают корректность, описывая с помощью кода требуемое состояние сред.
  - Безопасность и документация: Если за провизионирование всех вычислительных, сетевых и служб хранения отвечает код, они каждый раз будут развертываться одинаково. Это означает, что стандарты безопасности можно легко и последовательно применять в разных компаниях.
  - Рефакторинг: после того, как у вас есть написанный процесс превращения нескольких серверов в продакшен и вы можете повторять его снова и снова (малыми усилиями).
  - code review: Рефакторинг и хранение инструкций для системы управления конфигурациями в гите делает возможным проводить code review.

- Какой из принципов IaaC является основополагающим?

  - Идемпотентность - свойство объекта или операции при повторном применении операции к объекту давать тот же результат,
  что и при первом.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?

  -  Модули могут быть написаны почти на любом языке
  -  Не требуются агенты на управляемых узлах
  -  Веб-интерфейс позволяет настраивать пользователей, команды и оборудование, применять сценарии
  -  Очень просто настраивается и запускается

- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
  - push надёжней, т.к. централизованно управляет конфигурацией и исключает ситуации, когда прямое изменеие на сервере не отразится в репозитории, что может привести к непредсказуемым ситуациям. Но особое внимание надо уделить безопасности репозиториев CI/CD.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*
```
VMWare Workstation Pro 16.1
```
```
E:\Vagrant_VM\debian11>vagrant -v
Vagrant 2.2.19
```
```
vagrant@server1:~$ ansible --version
ansible 2.10.8
  config file = /home/vagrant/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]

```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
- Для выполнения практической части на Windows часть действий пришлось выполнить вручную.
1. Установить Vagrant и утилиты для VMWare.
2. С помощью vagrantfile поднять 2 виртуальные машины
* vagrantfile под VMWare
```ruby
# -*- mode: ruby -*-

ISO = "bento/debian-11"
NET = "192.168.0."
DOMAIN = ".netology"
HOST_PREFIX = "server"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "20",
    :ram => 1024,
    :core => 1
  },
  {
    :hostname => HOST_PREFIX + "2" + DOMAIN,
    :ip => NET + "30",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network",
        bridge: "Realtek PCIe GbE Family Controller",
		ip: machine[:ip]
      node.vm.provider "vmware_desktop" do |v|
        v.vmx["memsize"] = machine[:ram]
        v.vmx["numvcpus"] = machine[:core]
      end
    end
	# default router
	config.vm.provision "shell",
      run: "always",
      inline: "ip route del default"
	config.vm.provision "shell",
      run: "always",
      inline: "ip route add default via 192.168.0.1"
	config.vm.provision "shell",
      run: "always",
      inline: "apt update -y && apt dist-upgrade -y"
  end
end
```
3. На server1 установить ansible, создать inventory и playbook, сгенерировать ключи, и скопировать публичный ключ на server2.
* inventory
```
[nodes:children]
manager

[manager]
server2.netology ansible_host=192.168.0.30 ansible_user=root
```
* playbook
```yaml
---

  - hosts: nodes
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker
```
* Вывод результата
```bash
vagrant@server1:~$ ansible-playbook provision.yml

PLAY [nodes] *************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************
ok: [server2.netology]

TASK [Checking DNS] ******************************************************************************************************
changed: [server2.netology]

TASK [Installing tools] **************************************************************************************************
changed: [server2.netology] => (item=['git', 'curl'])

TASK [Installing docker] *************************************************************************************************
changed: [server2.netology]

TASK [Add the current user to docker group] ******************************************************************************
changed: [server2.netology]

PLAY RECAP ***************************************************************************************************************
server2.netology           : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
* server2
```bash
vagrant@server2:~$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
