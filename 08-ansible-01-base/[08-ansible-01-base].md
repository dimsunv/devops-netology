# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
    ```
    boliwar@netology:~$ ansible --version
    ansible [core 2.13.2rc1]
    ```
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
* [Repo](https://github.com/dimsunv/devops-netology/tree/08-ansible-01-base)
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
    ```
    boliwar@netology:~/08-ansible-01-base$ ansible-playbook -i inventory/test.yml site.yml

    PLAY [Print os facts] *********************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [localhost]

    TASK [Print OS] ***************************************************************************************************
    ok: [localhost] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] *************************************************************************************************
    ok: [localhost] => {
        "msg": 12
    }

    PLAY RECAP ********************************************************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

    ```
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
    ```
    version: '3'
    services:
      centos7:
        image: pycontribs/centos:7
        container_name: centos7
        restart: unless-stopped
        entrypoint: "sleep infinity"

      ubuntu:
        image: pycontribs/ubuntu
        container_name: ubuntu
        restart: unless-stopped
        entrypoint: "sleep infinity"
    ```
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
    ```
    boliwar@netology:~/08-ansible-01-base$ sudo ansible-playbook -i inventory/prod.yml site.yml

    PLAY [Print os facts] ****************************************************************************************************

    TASK [Gathering Facts] ***************************************************************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] **********************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] ********************************************************************************************************
    ok: [centos7] => {
        "msg": "el"
    }
    ok: [ubuntu] => {
        "msg": "deb"
    }
    ```
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
    ```
    PLAY [Print os facts] ****************************************************************************************************

    TASK [Gathering Facts] ***************************************************************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] **********************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] ********************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ```
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
    ```
    boliwar@netology:~/08-ansible-01-base$ ansible-vault encrypt group_vars/deb/examp.yml
    New Vault password:
    Confirm New Vault password:
    Encryption successful
    boliwar@netology:~/08-ansible-01-base$ ansible-vault encrypt group_vars/el/examp.yml
    New Vault password:
    Confirm New Vault password:
    Encryption successful
    ```
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
    ```
    boliwar@netology:~/08-ansible-01-base$ sudo ansible-playbook -i inventory/prod.yml site.yml

    PLAY [Print os facts] ****************************************************************************************************
    ERROR! Attempting to decrypt but no vault secrets found
    boliwar@netology:~/08-ansible-01-base$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
    Vault password:

    PLAY [Print os facts] ****************************************************************************************************

    TASK [Gathering Facts] ***************************************************************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] **********************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }
    ```
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
    ```
    local  -  execute on controller
    ```
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
    ```
    boliwar@netology:~/08-ansible-01-base$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
    Vault password:

    PLAY [Print os facts] ************************************************************************************

    TASK [Gathering Facts] ***********************************************************************************
    ok: [serv]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] ******************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }
    ok: [serv] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] ****************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ok: [serv] => {
        "msg": "all default fact"
    }
    ```
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
    ```
    boliwar@netology:~/08-ansible-01-base$ ansible-vault decrypt ./group_vars/el/examp.yml
    Vault password:
    Decryption successful
    boliwar@netology:~/08-ansible-01-base$ ansible-vault decrypt ./group_vars/deb/examp.yml
    Vault password:
    Decryption successful
    ```
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
    ```
    boliwar@netology:~/08-ansible-01-base$ ansible-vault encrypt_string
    New Vault password:
    Confirm New Vault password:
    Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
    PaSSw0rd
    Encryption successful
    !vault |
              $ANSIBLE_VAULT;1.1;AES256
              63633337623366386664313764643931396135313364336333643032346462653430316166613664
              3035626537616334653964323564616233376265333536660a663866366431343239633335303665
              34383465333130646131363538303334613565626339626561386265306665396466363665616432
              3065643337376264660a623562353533386263663232633636373132363466613366646639646330
              3739
    ```
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
    ```
    boliwar@netology:~/08-ansible-01-base$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
    Vault password:

    PLAY [Print os facts] ************************************************************************************

    TASK [Gathering Facts] ***********************************************************************************
    ok: [serv]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] ******************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }
    ok: [serv] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] ****************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ok: [serv] => {
        "msg": "PaSSw0rd"
    }
    ```
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
```
#!/usr/bin/env bash

docker-compose -f docker-compose.yml pull &&
docker-compose -f docker-compose.yml up -d &&
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass &&
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) &&
docker rmi $(docker images -a -q)
```
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.
```
boliwar@netology:~/08-ansible-01-base$ sudo bash script.sh
[+] Running 13/13
 ⠿ ubuntu Pulled                                                                                    91.1s
   ⠿ 423ae2b273f4 Pull complete                                                                     42.8s
   ⠿ de83a2304fa1 Pull complete                                                                     43.6s
   ⠿ f9a83bce3af0 Pull complete                                                                     43.8s
   ⠿ b6b53be908de Pull complete                                                                     44.1s
   ⠿ 7378af08dad3 Pull complete                                                                     88.8s
 ⠿ centos7 Pulled                                                                                   67.5s
   ⠿ 2d473b07cdd5 Pull complete                                                                     40.4s
   ⠿ 43e1b1841fcc Pull complete                                                                     45.6s
   ⠿ 85bf99ab446d Pull complete                                                                     65.2s
 ⠿ fedora Pulled                                                                                    74.1s
   ⠿ 588cf1704268 Pull complete                                                                     25.7s
   ⠿ 49425a0e12c7 Pull complete                                                                     71.9s
[+] Running 3/3
 ⠿ Container centos7  Started                                                                        3.3s
 ⠿ Container ubuntu   Started                                                                        2.8s
 ⠿ Container fedora   Started                                                                        3.4s
Vault password:

PLAY [Print os facts] ************************************************************************************

TASK [Gathering Facts] ***********************************************************************************
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] ******************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] ****************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "PaSSw0rd\n"
}

PLAY RECAP ***********************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

e6168d30b6bd
5aa450fa606a
f78d81fe4501
e6168d30b6bd
5aa450fa606a
f78d81fe4501
Untagged: pycontribs/fedora:latest
Untagged: pycontribs/fedora@sha256:20eeb45ef6e394947058dc24dc2bd98dfb7a8fecbbe6363d14ab3170f10a27ab
Deleted: sha256:c317904963299aca8e51353eb6be1227ca22bb08028e5a20e64e6eb6fe034d33
Deleted: sha256:1932a58d5cb0b34fe59775f0c8168046a14c29d3916e04588577933654bad018
Deleted: sha256:6d668c00f3f1bda56574dbf2f0a1d9210d2f3f902d7da7840ba15313347a5760
Untagged: pycontribs/centos:7
Untagged: pycontribs/centos@sha256:b3ce994016fd728998f8ebca21eb89bf4e88dbc01ec2603c04cc9c56ca964c69
Deleted: sha256:bafa54e44377836a27c12d9190ada20f834f87f1c6aa7069b3300811940c6e19
Deleted: sha256:68dae9c8312ec3f0fe4effb27d798a11dff9f853a0e7fd5e3b414cb5e592f229
Deleted: sha256:0cbf5ea0ac7fe354efbcb218e92df8a63e1f6830df47c8545faa4694236c59aa
Deleted: sha256:174f5685490326fc0a1c0f5570b8663732189b327007e47ff13d2ca59673db02
Untagged: pycontribs/ubuntu:latest
Untagged: pycontribs/ubuntu@sha256:dcb590e80d10d1b55bd3d00aadf32de8c413531d5cc4d72d0849d43f45cb7ec4
Deleted: sha256:42a4e3b21923371bd38cf7a072bafa19d21cf8f54398396102aed3989facc464
Deleted: sha256:4256330a39d49af087ef80c7d3acf3242232c230f68aefda31b7a0755bd712c5
Deleted: sha256:d3991ad41f89923dac46b632e2b9869067e94fcdffa3ef56cd2d35b26dd9bce7
Deleted: sha256:2e533c5c9cc8936671e2012d79fc6ec6a3c8ed432aa81164289056c71ed5f539
Deleted: sha256:282c79e973cf51d330b99d2a90e6d25863388f66b1433ae5163ded929ea7e64b
Deleted: sha256:cc4590d6a7187ce8879dd8ea931ffaa18bc52a1c1df702c9d538b2f0c927709d
```
---

[Repository](https://github.com/dimsunv/devops-netology/tree/08-ansible-01-base)
