# vagrant-hyperv-ansible

Sample Vagrantfile showing how to provision new Hyper-V machines with Ansible.

Default configuration will provision an Oracle Linux 8 VM with the following packages installed:

* Vim
* Git
* Docker + docker-compose
* Java
* Jenkins

Tested with Oracle Linux 8, but should work with any Red Hat 8 family distributions.

Support for Debian family distributions is not finalized.

## Notes

* Current version is using rsync to share folder between host and guest.
  * Don't use it if you need to share large amount of data since it will copy the files from host to guest. So it will consume space on you VM filesystem, but it may also delay the VM startup duration by several minutes.
  * Modifications on host folders are not automatically synced to the guest.
    * Use `rsync` or `rsync-auto`, cf. [Rsync](https://www.vagrantup.com/docs/synced-folders/rsync)
  * Prefer a sharing mechanism like SMB

## Prerequisities

* Vagrant. Tested on Vagrant  2.2.11
* Hyper-V features enabled on Windows Host

### Set Hyper-V as default provider

Either by settings the `VAGRANT_DEFAULT_PROVIDER` environment variable.

For example, using Powershell

* In the current session

```powershell
$Env:VAGRANT_DEFAULT_PROVIDER='hyperv'
```

* In your account's environment variables

```powershell
[Environment]::SetEnvironmentVariable('VAGRANT_DEFAULT_PROVIDER', 'hyperv', 'User')
```

Or by adding a VagrantFile in ~/.vagrant.d with the following content:

```rb
Vagrant.configure("2") do |config|
    config.vm.provider = 'hyperv'
end
```

## How to use it

* Clone this project on your Windows host

```shell
git@github.com:maguesse/vagrant-hyperv-ansible.git
```

* Modify configuration.yaml file for your own needs. See [Configuration variables](#configuration-variables) below.

* Modify [provisioning/vars/main.yaml](provisioning/vars/main.yaml) to match your needs.
  * Check each module's `Readme.md` to see supported variables and their default values.

## Configuration variables

Available variables are listed below, along with default values (see [configuration.yaml](./configuration.yaml))

```yaml
box: "generic/oracle8"
```

The vagrant base boxe

```yaml
forward_agent: true
forward_x11: true
```

Wether to enable forwarding between host and guest.

```yaml
domain="local.domain"
hostname_prefix="sagvm"
vm_category="box"
```

This will generate boxes with the following naming pattern `${hostname_prefix}${idx}-${vm_category}.${domain}`.
For example: `sagvm1-box.local.domain`

```yaml
boxes:
 -
  memory: 5120
  cpu: 2
  opts:
   primary: true
   autostart: true
```

Configures new machines. Parameters are self explanatory.

```yaml
 folders:
  -
   hostpath: "."
   guestpath: "/vagrant"
   type: "rsync"
   disabled: false
   opts:
    rsync__exclude:
     - ".git"
```

Configures synced folders between host and guest.
`opts` depend on synchronization implementation. Check Vagrant document for available options.

## Dependencies

* [geerlingguy.jenkins](https://github.com/geerlingguy/ansible-role-jenkins)
  * Install and configure Jenkins
* [geerlingguy.firewall](https://github.com/geerlingguy/ansible-role-firewall)
  * Install and configure iptables
* [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker)
  * Install and configure Docker
* [geerlingguy.java](https://github.com/geerlingguy/ansible-role-java)
  * Install Java from OS distribution's repositorie

## TODO

* Add support for Debian family distributions
* Configure a 2 ways folder sharing
  * Current rsync implementation does not support synchronization from the guest.
* Inject custom SSH keys
* Allocate static IP to guest machines

## Disclaimer

This configuration is provided as-is and without warranty or support.  Use it at your own risk.
