### Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

1. Есть скрипт:
    ```bash
        a=1
        b=2
        c=a+b
        d=$a+$b
        e=$(($a+$b))
    ```
      
    * Какие значения переменным c,d,e будут присвоены?
    * Почему?
    
   ```
    user@debian-11:~$ a=1
            b=2
            c=a+b
            d=$a+$b
            e=$(($a+$b))
    user@debian-11:~$ echo $c
    a+b
    user@debian-11:~$ echo $d
    1+2
    user@debian-11:~$ echo $e
    3
    user@debian-11:~$ 
    ```
    - `c=a+b` вернет `a+b` bash определит `a+b` как строку;
    - `d=$a+$b` вернет `1+2`, т.к. `a` и `b` с символом `$` будут интерпертированы как переменные, но запишется все в строку;
    - `e=$(($a+$b))` вернет `3`, т.к. конструкция `((..))` служит для арифметических операций.
    
2. На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
    ```
    #! usr/bin/env bash
    while ((1==1)
    do
    curl https://localhost:4757
    if (($? != 0))
    then
    date >> curl.log
    fi
    done
    ```

    ```
    #! usr/bin/env bash
    while ((1==1))              #отсутствует закрывающаяся скобка
    do
    curl https://localhost:4757
    if (($? != 0))
    then
    date >> curl.log
    else                        # отсутствует условие выхода
    break                     
    fi
    done
    ```
3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.
    ```
    #!/usr/bin/env bash
    declare -i attempt=1
    while (($attempt<=5))
    do
      for host in 192.168.0.1 173.194.222.113 87.250.250.242; do
        nmap -p 80 $host
        echo "status" $? $host `date` >> nmap_log.log
      done
    attempt+=1
    sleep 1
    done
    ```
4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается
    
    ```
    #!/usr/bin/env bash
    declare -i test=1
    while (($attempt==1))
    do
      for host in 192.168.0.1 173.194.222.113 87.250.250.242; do
        nmap -p 80 $host
        if (($?!=0))
        then
          echo "status" $? $host `date` >> nmap_error.log
          exit 0
        else
          echo "status" $? $host `date` >> nmap_done.log
        fi
      done
    sleep 1
    done
    ```
5. *Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: [04-script-01-bash] сломал хук.
    ```
    val=$(grep -c "\[[[:digit:]]*-[[:alpha:]]*-[[:digit:]]*-[[:alpha:]]*\]" "$1")
    len=$(cat "$1" | wc -m )
    
    if [[ "$val" -eq "0" ]]; then 
        echo -e "Commit message does not match format.\nPlease change your commit according to the pattern:\n\033[31m[number-lesson-number-lecture]\033[0m"
        exit 1
    elif [[ "$len" -gt "30" ]]; then 
        echo -e "\033[31mThe commit size exceeded 30 characters\033[0m"
        exit 1
    fi
    echo -e "\033[33mGood Commit!\033[0m"
    exit 0
    ```
    ```
    serafim@ROOT MINGW64 /e/myProject/test (master)
    $ git commit -m "01-script-03-bash"
    Commit message does not match format.
    Please change your commit according to the pattern:
    [number-lesson-number-lecture]
    
    serafim@ROOT MINGW64 /e/myProject/test (master)
    $ git commit -m "[01-script-03-bashrhfirhfiruhfuirhfuirhfuihruifhujvnsfvnasovnaonvunfuihruifhruif]"
    The commit size exceeded 30 characters
    
    serafim@ROOT MINGW64 /e/myProject/test (master)
    $ git commit -m "[01-script-03-bash]"
    Good Commit!
    [master 734c82a] [01-script-03-bash]
     2 files changed, 4 insertions(+), 2 deletions(-)
    ```