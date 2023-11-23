# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?("vagrant-hostmanager")
  raise  Vagrant::Errors::VagrantError.new, "vagrant-hostmanager plugin is missing. Please install it using 'vagrant plugin install vagrant-hostmanager' and rerun 'vagrant up'"
end

require "yaml"
settings = YAML.load_file "vagrant-settings.yaml"

IP_SECTIONS = settings["network"]["control_ip"].match(/^([0-9.]+\.)([^.]+)$/)
# First 3 octets including the trailing dot:
IP_NW = IP_SECTIONS.captures[0]
# Last octet excluding all dots:
IP_START = Integer(IP_SECTIONS.captures[1])
NUM_WORKER_NODES = settings["nodes"]["workers"]["count"]

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define "#{settings["nodes"]["control"]["name"]}" do |control|
    control.vm.hostname = settings["nodes"]["control"]["name"]
    control.vm.network :private_network, ip: settings["network"]["control_ip"]
    control.vm.provider "virtualbox" do |vb|
      vb.cpus = settings["nodes"]["control"]["cpu"]
      vb.memory = settings["nodes"]["control"]["memory"]
      if settings["cluster_name"] and settings["cluster_name"] != ""
        vb.customize ["modifyvm", :id, "--groups", ("/" + settings["cluster_name"])]
      end
    end
    control.vm.disk :disk, size: settings["nodes"]["control"]["disksize"], primary: true

    if settings["provisioning"]["enabled"]
      control.vm.provision "shell",
        path: "provisioning/common.sh"
      control.vm.provision "shell",
        path: "provisioning/control.sh"
    end
  end

  (1..NUM_WORKER_NODES).each do |i|
    config.vm.define "#{settings["nodes"]["workers"]["name"]}#{i}" do |node|
      node.vm.hostname = "#{settings["nodes"]["workers"]["name"]}#{i}"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.cpus = settings["nodes"]["workers"]["cpu"]
        vb.memory = settings["nodes"]["workers"]["memory"]
        if settings["cluster_name"] and settings["cluster_name"] != ""
          vb.customize ["modifyvm", :id, "--groups", ("/" + settings["cluster_name"])]
        end
      end
      node.vm.disk :disk, size: settings["nodes"]["workers"]["disksize"], primary: true

      if settings["provisioning"]["enabled"]
        node.vm.provision "shell",
          path: "provisioning/common.sh"
      end
    end
  end

  config.vm.provision "shell", reboot: true, inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get upgrade -y
  SHELL
end
