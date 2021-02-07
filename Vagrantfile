# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION ||= "2"
confDir = $config ||= File.expand_path(File.dirname(__FILE__))

# Little module to detect host OS
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
# Network not yes supported with hyper-v provider
NETWORK="" 
NETMASK="255.255.255.0"

boxes = [ 
  { :name => NAME_PREFIX + "1-" + VM_CATEGORY,  # VM hostname
    :eth1 => NETWORK + "2",                     # VM static IP  (not yet supported)
    :primary => true,                           # Is VM primary ?
    :workdir => "work/vm1" + "-" + VM_CATEGORY, # VM's shared folder with host (not yet supported)
    :memory => 5120 ,                           # VM's memory (in Mb)
    :cpus => 2,                                 # VM's allocated cores
    :autostart => true,                         # Should this VM be autstarted ?
    :fport => [{                                # Forwarded ports (not yet supported)
      :guest => 9000,                           #   Guest port
      :host => 9000}]                           #   Host port
  },
]

# List of folders to be synchronized with the guest
synced_folders = [
  {
    :hostpath => ".",             # Folder path on the host
    :guestpath => "/vagrant",     # Folder path on the guest
    :type => "rsync",             # Type of sync folder
    :disabled => false,           # If true, the sync folder won't be setup
    :opts => {                    # Additonal options. See each sync_folder type for available options
      :rsync__exclude => ".git"
    }
  },
  {
    :hostpath => "C:/Users/sagfagm/OneDrive - Software AG/Documents/02_SAG/99_Images",
    :guestpath => "/media/ImagesWm",
    :type => "rsync",
    :disabled => true
  },
  {
    :hostpath => "C:/Users/sagfagm/OneDrive - Software AG/Documents/02_SAG/98_Licenses",
    :guestpath => "/media/Licenses",
    :type => "rsync",
    :disabled => true
  },
]

# Windows Hack: Depending on "HOMEDRIVE" env variable, the "HOME" variable may differ from USERPROFILE env varibale
# This hack tries to fix this situation.
vagrant_home = (ENV['VAGRANT_HOME'].to_s.split.join.length > 0) ? ENV['VAGRANT_HOME'] : "#{ENV['HOME']}/.vagrant.d"
home = (OS.windows?) ? ENV['USERPROFILE'] : ENV['HOME']

# Main configuration
Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  
  # Enable X11 forwarding.
  config.ssh.forward_agent=true
  config.ssh.forward_x11=true

  # Attach Network interface to the VM
  config.vm.network "public_network", bridge: "Default Switch"

  # Configure synchronized folders
  synced_folders.each do |folder|
    opts = (folder[:opts] || {})
    config.vm.synced_folder folder[:hostpath], folder[:guestpath],
      type: folder[:type] ||= nil, 
      disabled: (folder[:disabled] || false),
      **opts
  end
  
  # For each box in boxes
  boxes.each do |box|
    config.vm.define box[:name], primary: box[:primary], autostart: box[:autostart] do |machine| 
      machine.vm.hostname = box[:name] + DOMAIN
      # Configure VM's resources allocation
      machine.vm.provider "hyperv" do |h|
        h.memory = box[:memory]
        h.maxmemory  = box[:memory]
        h.cpus = box[:cpus]
        h.vmname = box[:name]

        h.vm_integration_services = {
          guest_service_interface: true
        }
      end
      # Provision the target VM
      machine.vm.provision "ansible_local" do |ansible|
        ansible.verbose = false
        ansible.playbook = "provisioning/playbook.yaml"
        ansible.galaxy_role_file = "requirements.yml" 
        ansible.galaxy_roles_path = "galaxy_roles" 
      end
    end
  end
 
end
