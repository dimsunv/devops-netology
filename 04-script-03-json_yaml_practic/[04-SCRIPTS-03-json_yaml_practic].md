# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
```json
{
  "info": "Sample JSON output from our service\\t",
  "elements": [                                     
    {
      "name": "first",
      "type": "server",
      "ip": "71.75.x.x"                             
    },                                              
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"                           
    }
  ]
}                                                   
```
* 2 Неэкранированный спецсимвол ` \ `
* 3 Отсутстувет пробел
* 7 Неверный IP
* 8 Отсутствует `,`
* 12 Не хватает ковычек в ключе и значении
* И Code-Style `Ctrl+Alt+L`

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
import socket
import json
import yaml


def comparison(hosts):
    result = {}
    for key in hosts:
        result[key] = socket.gethostbyname(key)
    for i in hosts:
        if hosts[i] != result[i]:
            print(f'Error {i} IP mismatch {hosts[i]} --- {result[i]}')
            hosts[i] = result[i]
    return hosts


def json_funk(file):
    with open(file, 'r') as f:
        hosts = json.load(f)
    comparison(hosts)
    with open(file, 'w') as f:
        json.dump(hosts, f, indent=2, sort_keys=True)


def yaml_funk(file):
    with open(file, 'r') as f:
        hosts = yaml.safe_load(f)
    comparison(hosts)
    with open(file, 'w') as f:
        yaml.dump(hosts, f, indent=2, sort_keys=True)


json_funk('1.json')
yaml_funk('1.yml')
```

### Вывод скрипта при запуске при тестировании:
```
Error drive.google.com IP mismatch 142.250.185.78 --- 142.251.1.194
Error mail.google.com IP mismatch 142.250.186.69 --- 108.177.14.19
Error google.com IP mismatch 142.250.184.238 --- 173.194.221.102
Error drive.google.com IP mismatch 142.250.185.78 --- 142.251.1.194
Error mail.google.com IP mismatch 142.250.186.69 --- 108.177.14.19
Error google.com IP mismatch 142.250.184.238 --- 173.194.221.102
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "drive.google.com": "142.251.1.194",
  "google.com": "173.194.221.102",
  "mail.google.com": "108.177.14.19"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 142.251.1.194
google.com: 173.194.221.102
mail.google.com: 108.177.14.19
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
import sys
from os import path
import json
import yaml

file = sys.argv[1]
full_name = path.splitext(path.basename(file))


def check_json():
    with open(file, 'r', encoding='utf_8') as f:
        try:
            j = json.load(f)
            if full_name[1] == '.json':
                print('Это JSON', '\n', j)
            else:
                print('Это JSON', '\n', j)
                new_file = full_name[0] + '.json'
                with open(new_file, 'w') as n:
                    json.dump(j, n, indent=2, sort_keys=True)
        except json.decoder.JSONDecodeError as exc:
            print('Это не JSON, или в файле ошибка', '\n', exc)


def check_yaml():
    with open(file, 'r', encoding='utf_8') as f:
        try:
            y = yaml.safe_load(f)
            if full_name[1] == ('.yml', '.yaml'):
                print('Это YAML', '\n', y)
            else:
                print('Это YAML', '\n', y)
                new_file = full_name[0] + '.yml'
                with open(new_file, 'w') as n:
                    yaml.dump(y, n, indent=2, sort_keys=True)
        except yaml.scanner.ScannerError as exc:
            print('Это не YAML, или в файле ошибка', '\n', exc)


# Так как json начинается с { проверяем начало файла на спецсимвол и вызываем соответствующую функцию
def check_format():
    with open(file, 'r', encoding='utf_8') as f:
        if f.readline(1) in '{':
            print("похоже это JSON")
            check_json()
        else:
            print("Возможно это YAML")
            check_yaml()


# Проверяем расширение файла
if full_name[1] in ('', '.json', '.yaml', '.yml'):
    check_format()
else:
    print('Incorrect file format')
    exit(0)
```

### Пример работы скрипта:
```
(venv) E:\myProject\devops-netology\Practic>python test.py 2.yml
похоже это JSON
Это JSON
 {'drive.google.com': '142.251.1.194', 'google.com': '173.194.221.102', 'mail.google.com': '108.177.14.19'}
```