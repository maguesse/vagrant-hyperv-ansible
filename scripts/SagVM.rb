# encoding: utf-8

require 'ipaddr'

class SagVM

  def SagVM.convert_keys_to_symbol(options)
    # Converts keys to symbol. Required for double-splat operator (**)
    options.keys.each{|k| options[k.to_sym] = options.delete(k)}
  end

  def SagVM.convert_ip_to(ip, netmask)
    net = IPAddr.new(ip)
    baseip = net.mask(netmask)
    prefix = baseip.prefix()
    gateway = baseip.succ()
    cidr = "#{baseip}/#{prefix}"

    return baseip, cidr, gateway
  end

  def SagVM.configure(config, settings)

    # WIP: Do not uncomment
    # config.trigger.before :up do |trigger|
    #   trigger.info = "Creating new Hyper-V switches if it does not exists"

    #   settings['networks'].each do |network|
    #     base, cidr, gateway = SagVM.convert_ip_to(network['base'], network['netmask'])
    #     trigger.run = {
    #       privileged: "true",
    #       powershell_elevated_interactive: "true",
    #       path: "./scripts/create-privatenetwork-switch.ps1",
    #       # args: ['-VMSwitch', 'private_network',
    #       #         '-NatName', 'NatNetwork',
    #       #         '-IPGateway', gateway,
    #       #         '-Prefix', base,
    #       #         '-PrefixLength', cidr]
    #     }
    #   end
    # end


    config.vm.box = settings['box'] ||= "generic/oracle8"

    # Enable X11 forwarding.
    config.ssh.forward_agent = settings['forward_agent'] ||= true
    config.ssh.forward_x11 = settings['forward_x11'] ||= true

    # Attach synced folders
    if settings.include? 'folders'
      settings['folders'].each do |folder|
        opts = (folder['opts'] || {})
        convert_keys_to_symbol(opts)

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
      #ip = "#{settings['network']['ip_prefix']}.#{index+2}"
      opts = box['opts'] || {}
      convert_keys_to_symbol(opts)

      config.vm.define name, **opts do |machine|
        machine.vm.hostname = hostname
        # Attach Network interface to the VM
        machine.vm.network "public_network", bridge: "Default Switch"
        # WIP: Do not uncomment
        #settings['networks'].each_with_index do |network, index|
        #  puts network
        #  machine.vm.network network['type'], bridge: network['bridge']
        #end
        machine.vm.provider "hyperv" do |h|
          h.linked_clone = box['linked_clone'] ||= false
          h.enable_virtualization_extensions = box['enable_virtualization_extensions'] ||= false
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
end