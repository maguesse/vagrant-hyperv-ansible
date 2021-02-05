# Ansible Role : server-hardening

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    ssh_disable_root_access: true
    

Wether to disable root access on SSH.


    ssh_disable_password_authentication: false    

Wether to disable password authentication on SSH


## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - server-hardening

*Inside `vars/main.yaml`*:

    ssh_disable_password_authentication: true
