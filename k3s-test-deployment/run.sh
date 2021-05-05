#!/bin/bash

export DEFAULT_REMOTE_TMP=~/.ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./inventory -u root -k ./main.yaml
