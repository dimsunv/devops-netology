###Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

1. Есть скрипт:
    ```
    a = 1
    b = '2'
    c = a + b
    ```
    * Какое значение будет присвоено переменной c?
        - Интерпретатор выдаст ошибку - попытка сложения int со str.
    * Как получить для переменной c значение 12?
        - Если str - c = str(a) + b
        - Если int - c = str(a) + b
    * Как получить для переменной c значение 3?
        - c = a + int(b)

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?
    ```python
    #!/usr/bin/env python3
    
    import os
    
   
    bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break
    ```
    ```
    #!/usr/bin/env python3
    
    import os
    
   
    gitdir = "~/netology/sysadmin-homeworks"
    bash_command = [f"cd {gitdir}", "git status  | grep modified"]
    result_os = os.popen(' && '.join(bash_command)).read()
    
    if result_os.find('modified') != -1:
        print(result_os.replace('modified:', gitdir))
    ```

3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.
    ```
    #!/usr/bin/env python3
    
    import os
    import sys
    
    
    gitdir = ""
    
    try:
        gitdir = sys.argv[1] #проверка что путь задан
    except:
        print("Incorrect path")
        exit()
    
    try:
        path = os.listdir(sys.argv[1]) #проверка что путь - папка
    except NotADirectoryError:
        print("Incorrect path")
        exit()
    
    listpath = os.listdir(gitdir)
    
    if listpath.__contains__(".git"):
        bash_command = [f"cd {gitdir}", "git status  | grep modified"]
        result_os = os.popen(' && '.join(bash_command)).read()
        if result_os.find('modified') != -1:
            print(result_os.replace('modified:', gitdir))
    else:
        print("This folder is not a git repository")
    
    ```
4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.
    ```
    import socket
    
    
    hosts = {}
    result = {}
    
    with open("hosts.txt") as file:
        for line in file:
            key, value = line.split()
            hosts[key] = value
    
    for key in hosts:
        result[key] = socket.gethostbyname(key)
    
    with open("hosts.txt", 'w+') as file:
        for i in hosts:
            if hosts[i] != result[i]:
                print(f'Error {i} IP mismatch {hosts[i]} --- {result[i]}')
                file.write(f'{i} {result[i]}\n')
                added = 1
            else:
                print(f'{i} {hosts[i]}')
                file.write(f'{i} {hosts[i]}\n')
                added = 1
    ```
   
   ####hosts.txt
    ```
    drive.google.com  142.250.185.78
    mail.google.com  142.250.186.69
    google.com  142.250.184.238
    ```