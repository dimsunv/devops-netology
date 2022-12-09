#Quick start

- Add roles

```
ansible-galaxy install -r requirements.yml
```

- Add user to docker group in variables `group_vars`

```
---
docker_compose_version: "v2.14.0"
docker_users: []

pip_install_packages:
  - name: docker
  - name: docker-compose
```

- Complete inventory file

```
---
prod:
  hosts:
    opensearch-cluster:
      ansible_host:
    api-server:
      ansible_host:
    monitoring-server:
      ansible_host:
```

- Start playbook

```
ansible-playbook -i inventory/main.yml site.yml
```
