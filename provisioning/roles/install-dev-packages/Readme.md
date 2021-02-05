# Ansible Role : install-dev-packages

Install usefull package for development:
 - vim
 - wget
 - git

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)

None


## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - install-dev-packages

*Inside `vars/main.yaml`*:

    ---