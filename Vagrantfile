# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

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
end
