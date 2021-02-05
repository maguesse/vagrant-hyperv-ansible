# Ansible Role : install-java

Installs Azul Zulu Java.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    java_package: zulu-8


The Java version to be installed.

    java_yum_gpg_key: http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems
    java_yum_repo_name: /etc/yum.repos.d/zulu.repo
    java_yum_repo_url:  http://repos.azulsystems.com/rhel/zulu.repo

(Used only on RedHat family)

## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - install-java

*Inside `vars/main.yaml`*:

    java_package: zulu-11

## TODO

    - Support other Java distributions