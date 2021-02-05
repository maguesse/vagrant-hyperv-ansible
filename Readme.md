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


## Prerequisities

* Vagrant (obviously). Tested on Vagrant  2.2.11
* Hyper-V features enabled on Windows Host

### Set Hyper-V as default provider

Either by settings the `VAGRANT_DEFAULT_PROVIDER` environement variable. 

For example, using Powershell

* In the current session

		$Env:VAGRANT_DEFAULT_PROVIDER='hyperv'

* In your account's environment variables
	
		[Environment]::SetEnvironmentVariable('VAGRANT_DEFAULT_PROVIDER', 'hyperv', 'User')

Or by adding a VagrantFile in ~/.vagrant.d with the following content:

	Vagrant.configure("2") do |config|
		config.vm.provider = 'hyperv'
	end

## How to use it

* Clone this project on your Windows host

		git@github.com:maguesse/vagrant-hyperv-ansible.git

* Modify Vangrant file for your own needs

		DOMAIN=".eur.ad.sag"
		NAME_PREFIX="sagvm"
		VM_CATEGORY="box"

This will generate boxes with the following naming pattern `<NAME_PREFIX><idx>-<VM_CATEGORY><DOMAIN>`.
For example: `sagvm1-box.eur.ad.sag`

* Update the `boxes` list, especially `cpus` and `memory` values.

		boxes = [ 
		{ :name => NAME_PREFIX + "1-" + VM_CATEGORY,
			:eth1 => NETWORK + "2",
			:primary => true,
			:workdir => "work/vm1" + "-" + VM_CATEGORY,
			:memory => 5120 ,
			:cpus => 2,
			:autostart => true,
			:fport => [{
				:guest => 9000, 
				:host => 9000}]
		},

		]


Note: `eth1`, `fport` & `workdir` are currently not supported and will be ignored.

* Modify `provisioning/vars/main.yaml` to match your needs.
	* Check each module's Reamde.md to see supported variables and their default values.

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
