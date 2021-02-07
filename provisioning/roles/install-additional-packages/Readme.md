# Ansible Role : install-additional-packages

Installs additional packages.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `default/main.yaml`)


    additional_packages: []

Additional packages to be installed.

    additional_repos: []

Additonal repositories to be enabled.


## Dependencies

None

## Example playbook

    - hosts: all
    vars_files:
        - vars/main.yml
    roles:
        - install-additional-packages

*Inside `vars/main.yaml`*:

    additional_packages: 
        - firefox
        - emacs
        - x11-org-apps

    additonal_repos: [ "ol8_codeready_builder" ]
