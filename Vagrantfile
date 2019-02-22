# -*- mode: ruby -*-
# vi: set ft=ruby :

machineName = "windows"
gui = false
memory = 2048
cpus = 2

Vagrant.require_version ">= 1.8.4"

Vagrant.configure("2") do |config|
  config.vm.communicator = "winrm"

  config.vm.synced_folder ".", "/vagrant", disabled: true
  machineHome = ENV['HOME'].gsub('\\', '/')
  config.vm.synced_folder machineHome, machineHome

  config.vm.define "windows_2019_docker" do |cfg|
    # config.vm.box = "StefanScherer/windows_2019_docker"
    config.vm.box = "./windows_2019_docker_virtualbox.box"
    cfg.vm.provision "shell", path: "scripts/create-machine.ps1", args: "-machineHome #{machineHome} -machineName #{machineName}"
  end

  config.vm.provider "virtualbox" do |v, override|
    v.gui = gui
    v.memory = memory
    v.cpus = cpus
    v.linked_clone = true
    override.vm.network :private_network, ip: "192.168.99.90", gateway: "192.168.99.1"
  end
end
