#!/usr/bin/env bash

docker-compose -f docker-compose.yml pull &&
docker-compose -f docker-compose.yml up -d &&
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass &&
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) &&
docker rmi $(docker images -a -q)
