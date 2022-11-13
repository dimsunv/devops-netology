### Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

    - Разреженные – это специальные файлы, которые с большей эффективностью используют файловую систему, они не позволяют ФС занимать свободное дисковое пространство носителя, когда разделы не заполнены. То есть, «пустое место» будет задействовано только при необходимости. Пустая информация в виде нулей, будет хранится в блоке метаданных ФС. Поэтому, разреженные файлы изначально занимают меньший объем носителя, чем их реальный объем.

    - Обычный файл заполненный нулями
    ```shell
    $ dd if=/dev/zero of=output1 bs=1G count=4
    $ stat output1
    File: ouput1
      Size: 4294967296      Blocks: 8388616    IO Block: 4096   regular file
    ```
    - Разреженный файл заполненный нулями
    ```shell
    $ dd if=/dev/zero of=output2 bs=1G seek=0 count=0
    $ stat output2
    File: output2
      Size: 4294967296      Blocks: 0          IO Block: 4096   regular file
    ```

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

    - Нет, потому что это просто ссылки на один и тот же `inode` - в нём и хранятся права доступа и имя владельца.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```shell
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```
    - Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.
    - К сожалению `customize` работает только с Virtual Box. Поэтому я создал ВМ Debian с тремя жесткими дисками.
   ```
    root@debian-11:~# lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda      8:0    0   10G  0 disk 
    ├─sda1   8:1    0    9G  0 part /
    ├─sda2   8:2    0    1K  0 part 
    └─sda5   8:5    0  975M  0 part [SWAP]
    sdb      8:16   0    3G  0 disk 
    sdc      8:32   0    3G  0 disk 
    sr0     11:0    1  3,6G  0 rom  
    root@debian-11:~# fdisk /dev/sdb
    ```
4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
    ```
    root@debian-11:~# fdisk /dev/sdb
    
    Welcome to fdisk (util-linux 2.36.1).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.
    
    Device does not contain a recognized partition table.
    Created a new DOS disklabel with disk identifier 0x08ae09e3.
    
    Command (m for help): F
    Unpartitioned space /dev/sdb: 3 GiB, 3220176896 bytes, 6289408 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    
    Start     End Sectors Size
     2048 6291455 6289408   3G
    
    Command (m for help): n
    Partition type
       p   primary (0 primary, 0 extended, 4 free)
       e   extended (container for logical partitions)
    Select (default p): p
    Partition number (1-4, default 1): 
    First sector (2048-6291455, default 2048): 
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-6291455, default 6291455): +2Gb
    
    Created a new partition 1 of type 'Linux' and of size 1,9 GiB.
    
    Command (m for help): n
    Partition type
       p   primary (1 primary, 0 extended, 3 free)
       e   extended (container for logical partitions)
    Select (default p): p
    Partition number (2-4, default 2): 
    First sector (3907584-6291455, default 3907584): 
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (3907584-6291455, default 6291455): 
    
    Created a new partition 2 of type 'Linux' and of size 1,1 GiB.
    
    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```
5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
    ```
    root@debian-11:~# sfdisk -d /dev/sdb > sdb.dump
    root@debian-11:~# sfdisk /dev/sdc < sdb.dump
    Checking that no-one is using this disk right now ... OK
    
    Disk /dev/sdc: 3 GiB, 3221225472 bytes, 6291456 sectors
    Disk model: VMware Virtual S
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Created a new DOS disklabel with disk identifier 0x08ae09e3.
    /dev/sdc1: Created a new partition 1 of type 'Linux' and of size 1,9 GiB.
    /dev/sdc2: Created a new partition 2 of type 'Linux' and of size 1,1 GiB.
    /dev/sdc3: Done.
    
    New situation:
    Disklabel type: dos
    Disk identifier: 0x08ae09e3
    
    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdc1          2048 3907583 3905536  1,9G 83 Linux
    /dev/sdc2       3907584 6291455 2383872  1,1G 83 Linux
    
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```
6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.
    ```
    root@debian-11:/etc/apt# mdadm -V
    mdadm - v4.1 - 2018-10-01
    root@debian-11:/etc/apt# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
    mdadm: Note: this array has metadata at the start and
        may not be suitable as a boot device.  If you plan to
        store '/boot' on this device please ensure that
        your boot-loader understands md/v1.x metadata, or use
        --metadata=0.90
    Continue creating array? y
    mdadm: Defaulting to version 1.2 metadata
    mdadm: array /dev/md0 started.
    ```
7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.
    ```
    root@debian-11:/etc/apt# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]2
    mdadm: Defaulting to version 1.2 metadata
    mdadm: array /dev/md1 started.
    ```
8. Создайте 2 независимых PV на получившихся md-устройствах.
    ```
    root@debian-11:/etc/apt# pvcreate /dev/md0
    Physical volume "/dev/md0" successfully created.
    root@debian-11:/etc/apt# pvcreate /dev/md1
    Physical volume "/dev/md1" successfully created.
    ```
9. Создайте общую volume-group на этих двух PV.
    ```
    root@debian-11:/etc/apt# vgcreate testgroup /dev/md0 /dev/md1
    Volume group "testgroup" successfully created
    ```
10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
    ```
    root@debian-11:/etc/apt# lvcreate -L 100m -n testgroup-lv testgroup /dev/md1
    Logical volume "testgroup-lv" created.
    ```
11. Создайте `mkfs.ext4` ФС на получившемся LV.
    ```
    root@debian-11:/etc/apt# mkfs.ext4 -L testgroup-ext4 -m 1 /dev/mapper/testgroup-testgroup--lv
    mke2fs 1.46.2 (28-Feb-2021)
    Creating filesystem with 102400 1k blocks and 25688 inodes
    Filesystem UUID: 2c173b81-f15e-49ca-af2c-d2db41a2e964
    Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729
    
    Allocating group tables: done                            
    Writing inode tables: done                            
    Creating journal (4096 blocks): done
    Writing superblocks and filesystem accounting information: done 
    ```
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
    ```
    root@debian-11:/etc/apt# mkdir /tmp/new
    root@debian-11:/etc/apt# mount /dev/mapper/testgroup-testgroup--lv /tmp/new/
    root@debian-11:/etc/apt# mount | grep testgroup-testgroup--lv
    /dev/mapper/testgroup-testgroup--lv on /tmp/new type ext4 (rw,relatime,stripe=1024)
    ```
13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
    ```
    root@debian-11:/etc/apt# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
    --2022-02-02 00:15:07--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
    Распознаётся mirror.yandex.ru (mirror.yandex.ru)… 213.180.204.183, 2a02:6b8::183
    Подключение к mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... соединение установлено.
    HTTP-запрос отправлен. Ожидание ответа… 200 OK
    Длина: 22113959 (21M) [application/octet-stream]
    Сохранение в: «/tmp/new/test.gz»
    
    /tmp/new/test.gz                           100%[=====================================================================================>]  21,09M  7,04MB/s    за 3,0s    
    
    2022-02-02 00:15:11 (7,04 MB/s) - «/tmp/new/test.gz» сохранён [22113959/22113959]
    ```
14. Прикрепите вывод `lsblk`.
    ```
    root@debian-11:/etc/apt# lsblk
    NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    sda                             8:0    0   10G  0 disk  
    ├─sda1                          8:1    0    9G  0 part  /
    ├─sda2                          8:2    0    1K  0 part  
    └─sda5                          8:5    0  975M  0 part  [SWAP]
    sdb                             8:16   0    3G  0 disk  
    ├─sdb1                          8:17   0  1,9G  0 part  
    │ └─md0                         9:0    0  1,9G  0 raid1 
    └─sdb2                          8:18   0  1,1G  0 part  
      └─md1                         9:1    0  2,3G  0 raid0 
        └─testgroup-testgroup--lv 253:0    0  100M  0 lvm   /tmp/new
    sdc                             8:32   0    3G  0 disk  
    ├─sdc1                          8:33   0  1,9G  0 part  
    │ └─md0                         9:0    0  1,9G  0 raid1 
    └─sdc2                          8:34   0  1,1G  0 part  
      └─md1                         9:1    0  2,3G  0 raid0 
        └─testgroup-testgroup--lv 253:0    0  100M  0 lvm   /tmp/new
    sr0                            11:0    1  3,6G  0 rom   
    ```
15. Протестируйте целостность файла:
    ```
    root@debian-11:/etc/apt# gzip -t /tmp/new/test.gz >> /dev/null; echo $?
    0
    ```
16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
    ```
    root@debian-11:/etc/apt# pvmove -n testgroup-lv /dev/md1 /dev/md0
    /dev/md1: Moved: 52,00%
    /dev/md1: Moved: 100,00%
    ```
17. Сделайте `--fail` на устройство в вашем RAID1 md.
    ```
    root@debian-11:/etc/apt# mdadm --fail /dev/md0 /dev/sdb1
    mdadm: set /dev/sdb1 faulty in /dev/md0
    ```
18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
    ```
    root@debian-11:/etc/apt# dmesg | grep md0 | tail -n 2
    [ 6185.763684] md/raid1:md0: Disk failure on sdb1, disabling device.
                   md/raid1:md0: Operation continuing on 1 devices.
    ```
19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
    ```
    root@debian-11:/etc/apt# gzip -t /tmp/new/test.gz >> /dev/null; echo $?
    0
    ```
20. Погасите тестовый хост, vagrant destroy.
    