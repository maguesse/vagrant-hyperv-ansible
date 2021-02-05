# Ansible Role : install-java

Installs alternative Java distributions.

Currenly supported:
- Azul Zulu
- AdoptOpenJDK

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    java_packages: []


The Java version to be installed.

    install_repositories: []

Alternate repositories to install.

## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - install-java

*Inside `vars/main.yaml`*:

    java_packages: zulu11
    install_repositories: [ "Azul" ]

## TODO

    - Support other Java distributions
    - Install repositories only for selected java_packages