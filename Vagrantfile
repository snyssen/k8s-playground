# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?("vagrant-disksize")
  raise  Vagrant::Errors::VagrantError.new, "vagrant-disksize plugin is missing. Please install it using 'vagrant plugin install vagrant-disksize' and rerun 'vagrant up'"
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.disksize.size = '70GB'

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 2
  end

  controlPlaneNodeName = "c1-cp1"
  config.vm.define "#{controlPlaneNodeName}" do |controlPlaneNode|
    controlPlaneNode.vm.hostname = "#{controlPlaneNodeName}"
    controlPlaneNode.vm.network :private_network, ip: "192.168.56.20"
  end

  N = 3
  (1..N).each do |i|
    nodeName = "c1-node#{i}"
    config.vm.define "#{nodeName}" do |node|
      node.vm.hostname = "#{nodeName}"
      node.vm.network :private_network, ip: "192.168.56.2#{i}"
    end
  end

  # Run initial upgrade on provisioning and reboot so we have the machine ready to go
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update && sudo apt upgrade -y && sudo reboot
  SHELL
end
