# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  #config.vm.box = "ubuntu/vivid64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: "192.168.43.10"
    master.vm.hostname = "master"

    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 5050, host: 5050

    master.vm.provision "shell", path: "boot_master.sh"

  end

  config.vm.define "slave" do |slave|

    slave.vm.network "private_network", ip: "192.168.43.11"
    slave.vm.hostname = "slave"

    slave.vm.provision "shell", path: "boot_slave.sh", args: "192.168.43.11"

  end

  config.vm.define "slave2" do |slave|
  
    slave.vm.network "private_network", ip: "192.168.43.12"
    slave.vm.hostname = "slave"

    slave.vm.provision "shell", path: "boot_slave.sh", args: "192.168.43.12"

  end
end
