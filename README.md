Ansible Collection - boliwar.homework

Installation

```
ansible-galaxy collection install git+https://github.com/dimsunv/devops-netology.git,08-ansible-06-modules
```

Usage

```
---
- name: create file
  hosts: localhost
  tasks:
    - name: create file
      boliwar.homework.file:
        path: "/tmp/test_file.txt"
        content: "Hello world"
```

```
---
- hosts: localhost
  roles:
    - boliwar.homework.file
```
