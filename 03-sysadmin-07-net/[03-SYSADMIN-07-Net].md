### Домашнее задание к занятию "Компьютерные сети, лекция 2"

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

    - Linux `ip link show`, `ip a`
    - Windows `ipconfig /all`
    ```vagrant@debian-11:~$ ip link show
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether 00:0c:29:b8:51:f7 brd ff:ff:ff:ff:ff:ff
        altname enp2s0
        altname ens32
    vagrant@debian-11:~$ ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 00:0c:29:b8:51:f7 brd ff:ff:ff:ff:ff:ff
        altname enp2s0
        altname ens32
        inet 192.168.10.50/24 brd 192.168.10.255 scope global dynamic eth0
           valid_lft 1611sec preferred_lft 1611sec
        inet6 fe80::20c:29ff:feb8:51f7/64 scope link 
           valid_lft forever preferred_lft forever
    vagrant@debian-11:~$ 
    ```
2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
    
    - Протокол `LLDP`. Пакет `lldpd`. Команда `lldpctl`.
    ```
    vagrant@debian-11:~$ sudo lldpctl
    -------------------------------------------------------------------------------
    LLDP neighbors:
    -------------------------------------------------------------------------------
    Interface:    eth0, via: LLDP, RID: 1, Time: 0 day, 00:02:54
      Chassis:     
        ChassisID:    mac 00:50:56:c0:00:08
      Port:        
        PortID:       mac 00:50:56:c0:00:08
        TTL:          3601
        PMD autoneg:  supported: yes, enabled: yes
          Adv:          1000Base-T, HD: no, FD: yes
          MAU oper type: unknown
      LLDP-MED:    
        Device Type:  Generic Endpoint (Class I)
        Capability:   Capabilities, yes
    -------------------------------------------------------------------------------
    ```

3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.  
    
    Технология называется VLAN (Virtual LAN).  
    Пакет в Linux - vlan  
    
    ```
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).
    
    source /etc/network/interfaces.d/*
    
    # The loopback network interface
    auto lo
    iface lo inet loopback
    
    # The primary network interface
    #allow-hotplug enp0s3
    auto ens3.500
    iface ens3 inet static
    address 192.168.0.10
    netmask 255.255.255.0
    gateway 192.168.0.1
    
    
    auto ens4.501
    iface ens4 inet static
    address 192.168.1.10
    netmask 255.255.255.0
    gateway 192.168.1.1
    ```

4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.  
    
    #####В Linux есть две технологии агрегации (LAG): bonding и teaming.  
    
    #####Типы агрегации bonding:
    
    ```
    root@debian11:~# modinfo bonding | grep mode:
    parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
    ```
    
    - `active-backup` и `broadcast` обеспечивают только отказоустойчивость  
    - `balance-tlb`, `balance-alb`, `balance-rr`, `balance-xor` и `802.3ad` обеспечат отказоустойчивость и балансировку
    - `balance-rr` - Политика round-robin. Пакеты отправляются последовательно, начиная с первого доступного интерфейса и заканчивая последним. Эта политика применяется для балансировки нагрузки и отказоустойчивости.  
    - `active-backup` - Политика активный-резервный. Только один сетевой интерфейс из объединённых будет активным. Другой интерфейс может стать активным, только в том случае, когда упадёт текущий активный интерфейс. Эта политика применяется для отказоустойчивости.  
    - `balance-xor` - Политика XOR. Передача распределяется между сетевыми картами используя формулу: [( «MAC адрес источника» XOR «MAC адрес назначения») по модулю «число интерфейсов»]. Получается одна и та же сетевая карта передаёт пакеты одним и тем же получателям. Политика XOR применяется для балансировки нагрузки и отказоустойчивости.  
    - `broadcast` - Широковещательная политика. Передает всё на все сетевые интерфейсы. Эта политика применяется для отказоустойчивости.  
    - `802.3ad` - Политика агрегирования каналов по стандарту IEEE 802.3ad. Создаются агрегированные группы сетевых карт с одинаковой скоростью и дуплексом. При таком объединении передача задействует все каналы в активной агрегации, согласно стандарту IEEE 802.3ad. Выбор через какой интерфейс отправлять пакет определяется политикой по умолчанию XOR политика.  
    - `balance-tlb` - Политика адаптивной балансировки нагрузки передачи. Исходящий трафик распределяется в зависимости от загруженности каждой сетевой карты (определяется скоростью загрузки). Не требует дополнительной настройки на коммутаторе. Входящий трафик приходит на текущую сетевую карту. Если она выходит из строя, то другая сетевая карта берёт себе MAC адрес вышедшей из строя карты.  
    - `balance-alb` - Политика адаптивной балансировки нагрузки. Включает в себя политику balance-tlb плюс осуществляет балансировку входящего трафика. Не требует дополнительной настройки на коммутаторе. Балансировка входящего трафика достигается путём ARP переговоров.  
    
    ```
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).
    
    source /etc/network/interfaces.d/*
    
    # The loopback network interface
    auto lo
    iface lo inet loopback
    
    # First interface enp3s0f0
    auto ens3
    iface ens3 inet manual
      bond-master bond0
    
    # Second interface ens4
    auto ens4
    iface ens4 inet manual
      bond-master bond0
    
    # Frontend bond interface
    auto bond0
    iface bond0 inet static
      address 192.168.0.10/24
      gateway 192.168.0.1
      bond-mode 802.3ad
      bond-miimon 100
      bond-lacp-rate 1
    ```

5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
    
    - 8 доступных адресов
    
    - Сеть с маской /24(256 доступных адресов) можно разбить на 32 подсети с маской /29
    
6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.
    
    - Можно взять адреса из сети для CGNAT - 100.64.0.0/10.
    
    - Маска для диапазонов будет /26, она позволит подключить 62 хоста.

7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
    
    #####Проверить таблицу можно так:
    
    - Linux: `ip neigh`, `arp -n`
    - Windows: `arp -a`
    
    #####Очистить кеш так:
    
    - Linux: `ip neigh flush`
    - Windows: `arp -d *`
    
    #####Удалить один IP так:
    
    - Linux: `ip neigh delete <IP> dev <INTERFACE>`, `arp -d <IP>`
    - Windows: `arp -d <IP>`