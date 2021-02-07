# Ansible Role : install-minimal-packages

Install minimal packages:
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
        - install-minimal-packages

*Inside `vars/main.yaml`*:

    ---