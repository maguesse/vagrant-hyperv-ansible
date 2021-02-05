# -*- mode: ruby -*-
# vi: set ft=ruby :
# Petit module permettant de détecter l'OS Host
module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end

  def OS.jruby?
    RUBY_ENGINE == 'jruby'
  end
end

DOMAIN=".eur.ad.sag"
NAME_PREFIX="sagvm"
VM_CATEGORY="box"
NETWORK="" # Not yet supported with hyper-v provider
NETMASK="255.255.255.0"

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

# Petit hack pour essayer de bypasser le fait que sous Windows, Vagrant décuit le répertoire "home"
# du user à partir de la variable "HOMEDRIVE". Or cette dernière peut ne pas être équivalente à USERPROFILE. 
vagrant_home = (ENV['VAGRANT_HOME'].to_s.split.join.length > 0) ? ENV['VAGRANT_HOME'] : "#{ENV['HOME']}/.vagrant.d"
home = (OS.windows?) ? ENV['USERPROFILE'] : ENV['HOME']

Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  
  config.ssh.forward_agent=true
  config.ssh.forward_x11=true

  config.vm.network "public_network", bridge: "Default Switch"
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git"

  boxes.each do |box|
    config.vm.define box[:name], primary: box[:primary], autostart: box[:autostart] do |machine| 
      machine.vm.hostname = box[:name] + DOMAIN
      machine.vm.provider "hyperv" do |h|
        h.memory = box[:memory]
        h.maxmemory  = box[:memory]
        h.cpus = box[:cpus]
        h.vmname = box[:name]

        h.vm_integration_services = {
          guest_service_interface: true
        }
      end
      machine.vm.provision "ansible_local" do |ansible|
        ansible.verbose = false
        ansible.playbook = "provisioning/playbook.yaml"
        ansible.galaxy_role_file = "requirements.yml" 
        ansible.galaxy_roles_path = "galaxy_roles" 
      end
    end
  end
 
end
