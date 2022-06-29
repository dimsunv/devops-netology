# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`. Обратите внимание, что `strace` выдаёт результат своей работы в поток stderr, а не в stdout.

    ```
    chdir("/tmp")                           = 0
    ```

1. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
    
    - Файл базы данных - `/usr/share/misc/magic.mgc`
    ```
    vagrant@debian-11:~$ strace -t file 1.txt
   
    12:48:32 openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
    ```
    
1. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
    ```
    vagrant@debian-11:~$ ping -i 5 ya.ru > my_file.txt &
    [1] 506
    vagrant@debian-11:~$ cat my_file.txt
    PING ya.ru (87.250.250.242) 56(84) bytes of data.
    64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=128 time=17.8 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=3 ttl=128 time=18.8 ms
    vagrant@debian-11:~$ rm my_file.txt
    vagrant@debian-11:~$ cat my_file.txt
    cat: my_file.txt: No such file or directory
    vagrant@debian-11:~$ sudo lsof -p 506 | grep my_file.txt
    ping    506 vagrant    1w   REG  254,0      751 2621465 /home/vagrant/my_file.txt (deleted)
    vagrant@debian-11:~$ sudo cat /proc/506/fd/1 > /home/vagrant/my_file.txt
    vagrant@debian-11:~$ cat my_file.txt
    PING ya.ru (87.250.250.242) 56(84) bytes of data.
    64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=128 time=17.8 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=3 ttl=128 time=18.8 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=4 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=5 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=6 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=7 ttl=128 time=19.0 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=8 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=9 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=10 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=11 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=12 ttl=128 time=18.6 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=13 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=14 ttl=128 time=18.7 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=15 ttl=128 time=18.9 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=16 ttl=128 time=18.4 ms
    64 bytes from ya.ru (87.250.250.242): icmp_seq=17 ttl=128 time=17.9 ms
    ```
1. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
    - До тех пор пока zombie не удален из системы с помощью wait, он будет использовать слот в таблице процессов ядра, и если эта таблица заполнится, создание новых процессов будет невозможно.

1. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
    ```
    PID    COMM               FD ERR PATH
    384    vmtoolsd            7   0 /proc/meminfo
    384    vmtoolsd            7   0 /proc/vmstat
    384    vmtoolsd            7   0 /proc/stat
    384    vmtoolsd            7   0 /proc/zoneinfo
    384    vmtoolsd            7   0 /proc/uptime
    384    vmtoolsd            7   0 /proc/diskstats
    ```
1. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.
    ```
    vagrant@debian-11:~$ strace uname -a
    uname({sysname="Linux", nodename="debian-11", ...}) = 0
   
    vagrant@debian-11:~$ uname -a
    Linux debian-11 5.10.0-10-amd64 #1 SMP Debian 5.10.84-1 (2021-12-08) x86_64 GNU/Linux
    vagrant@debian-11:~$ cat /proc/version
    Linux version 5.10.0-10-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.2) #1 SMP Debian 5.10.84-1 (2021-12-08)
    ```
1. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?
    
    - Оператор `&&` выполнит вторую команду только в том случае, если команда 1 успешно выполнена. Оператор `;` выполняет несколько команд одновременно последовательно, как упоминалось, и обеспечивает вывод без зависимости от успеха и отказа других команд.
    - Нет. Если установить  `set -e` оболочка завершает работу, когда простая команда в списке команд завершается ненулевым значением. 
    
    
1. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
    - Директива `set -e` не работает при работе с конвейерными командами. Когда сценарий вернет ошибку, но продолжит выполнять следующую команду. Чтобы предотвратить это, надо установить директиву `set -eo pipefail`
    - `-x` `xtrace` Режим отладки. Перед выполнением команды печатает её со всеми уже развернутыми подстановками и вычислениями.
    - `-u` обрабатывает неустановленные или неопределенные переменные, за исключением специальных параметров, таких как подстановочные знаки (*) или «@», как ошибки во время раскрытия параметра.
    - Директива `set -euxo pipefail` must have для обработки распространненых ошибок в сценариях.

1. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
    ```
    vagrant@debian-11:~$ ps -o stat
    STAT
    Ss
    R+
    ```
    - Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will display to describe the state of a process:
        - `D`    uninterruptible sleep (usually IO)
        - `I`    Idle kernel thread
        - `R`    running or runnable (on run queue)
        - `S`    interruptible sleep (waiting for an event to complete)
        - `T`    stopped by job control signal
        - `t`    stopped by debugger during the tracing
        - `W`    paging (not valid since the 2.6.xx kernel)
        - `X`    dead (should never be seen)
        - `Z`    defunct ("zombie") process, terminated but not reaped by its parent

    - For BSD formats and when the stat keyword is used, additional characters may be displayed:
        - `< `   high-priority (not nice to other users)
        - `N `   low-priority (nice to other users)
        - `L  `  has pages locked into memory (for real-time and custom IO)
        - `s`    is a session leader
        - `l`    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
        - `+ `   is in the foreground process group