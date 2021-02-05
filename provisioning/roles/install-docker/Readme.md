# Ansible Role : install-docker

Installs docker and docker-compose

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    docker_edition: 'ce'
    docker_package: 'docker-{{ docker_edition }}'
    docker_package_state: present

The `docker_edition` should be either `ce` (Community Edition) od `ee` (Enterprise Edition)

    docker_service_state: started
    docker_service_enabled: true
    docker_restart_handler_state: restarted

Variables to control the state of `docker` service, and whether it should start on boot.

    docker_compose_install: true
    docker_compose_version: "latest"
    docker_compose_release_url: "https://api.github.com/repos/docker/compose/releases/latest"
    docker_compose_url: "https://github.com/docker/compose/releases/download"
    docker_compose_path: "/usr/local/bin/docker-compose"

Docker Compose  installation options

    docker_yum_repo_url: https://download.docker.com/linux/{{ (ansible_distribution == "Fedora") | ternary("fedora","centos") }}/docker-{{ docker_edition }}.repo
    docker_yum_gpg_key: "https://download.docker.com/linux/centos/gpg"

(Used only on RedHat family) 

    docker_users: []

A list of system users to be added to the docker group.

## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - install-docker

*Inside `vars/main.yaml`*:

    docker_users: ["vagrant"]
