# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.require_version '>= 2.1.0'

VAGRANTFILE_API_VERSION ||= "2"
confDir = $config ||= File.expand_path(File.dirname(__FILE__))

configFile = confDir + "/configuration.yaml"

require File.expand_path(File.dirname(__FILE__) + '/scripts/SagVM.rb')

# Main configuration
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  if File.exists? configFile then
    settings = YAML::load(File.read(configFile))
  else 
    abort "Configuration file not found in #{confDir}"
  end

  SagVM.configure(config, settings)

end
