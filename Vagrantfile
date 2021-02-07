# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

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

# Windows Hack: Depending on "HOMEDRIVE" env variable, the "HOME" variable may differ from USERPROFILE env varibale
# This hack tries to fix this situation.
vagrant_home = (ENV['VAGRANT_HOME'].to_s.split.join.length > 0) ? ENV['VAGRANT_HOME'] : "#{ENV['HOME']}/.vagrant.d"
home = (OS.windows?) ? ENV['USERPROFILE'] : ENV['HOME']

configFile = confDir + "/configuration.yaml"

if File.exists? configFile then
  settings = YAML::load(File.read(configFile))
else 
  abort "Configuration file not found in #{confDir}"
end

# Main configuration
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = settings['box'] || "generic/oracle8"
  
  # Enable X11 forwarding.
  config.ssh.forward_agent = settings['forward_agent'] || true
  config.ssh.forward_x11 = settings['forward_x11'] || true

  # Attach Network interface to the VM
  config.vm.network "public_network", bridge: "Default Switch"

  # Attach synced folders
  if settings.include? 'folders'
    settings['folders'].each do |folder|
      opts = (folder['opts'] || {})
      # Converts keys to symbol. Required for double-splat operator (**)
      opts.keys.each{|k| opts[k.to_sym] = opts.delete(k)}

      config.vm.synced_folder folder['hostpath'], folder['guestpath'],
          type: folder['type'] ||= nil,
          disabled: folder['disabled'] ||= false,
          **opts
    end
  end

  # For each box in boxes
  settings['boxes'].each_with_index do |box, index|
    name = "#{settings['hostname_prefix']}#{index+1}-#{settings['vm_category']}"
    hostname = "#{name}.#{settings['domain']}"
    ip = "#{settings['network']['ip_prefix']}.#{index+2}"
    opts = box['opts'] || {}
    opts.keys.each{|k| opts[k.to_sym] = opts.delete(k)}

    config.vm.define name, **opts do |machine|
      machine.vm.hostname = hostname
      # Configure VM's resources allocation
      machine.vm.provider "hyperv" do |h|
        h.memory = box['memory']
        h.maxmemory  = box['memory']
        h.cpus = box['cpu']
        h.vmname = name

        h.vm_integration_services = {
          guest_service_interface: true
        }
      end
      #Provision the target VM
      machine.vm.provision "ansible_local" do |ansible|
        ansible.verbose = false
        ansible.playbook = "provisioning/playbook.yaml"
        ansible.galaxy_role_file = "requirements.yml" 
        ansible.galaxy_roles_path = "galaxy_roles" 
      end
    end
  end 
end
