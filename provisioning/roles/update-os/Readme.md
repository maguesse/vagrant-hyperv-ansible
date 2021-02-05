# Ansible Role : update-os

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    locale_language: en_US.UTF-8
    locale_keyboard: fr

Controls the system locale.


    datetime_timezone: Europe/Paris
    datetime_local_rtc: 0

Controls this system datetime


    sysctl_config: {}

Controls the kernel parameters.


    limits_configs: []

Controls users limits.

## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - update-os

*Inside `vars/main.yaml`*:

    locale_language: fr_FR.UTF-8

    sysctl_config: { 
    vm.max_map_count: 262144,
    fs.file-max: 250000,
    kernel.shmmax: 629145600
    }

    # Users limits config
    limits_configs: [
    {
        domain: "vagrant",
        type: "soft",
        item: "nofile",
        value: "250000"
    },
    {
        domain: "vagrant",
        type: "hard",
        item: "nofile",
        value: "250000"
    },

    ]

