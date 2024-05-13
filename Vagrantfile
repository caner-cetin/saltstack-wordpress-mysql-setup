# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder "./scripts", "/vagrant/scripts", type: "rsync"
  config.vm.define :centos9 do |centos9|
    centos9.vm.box = "generic/centos9s"
    centos9.vm.hostname = "centos9"
    centos9.vm.network :private_network, ip: "10.0.0.10"
    centos9.vm.network "forwarded_port", guest: 443, host: 33222
    centos9.vm.provision "shell", path: "./scripts/install-minion.sh", args: ["10.10.28.69", "centos9"]
  end

  config.vm.define :ubuntu22 do |ubuntu22|
    ubuntu22.vm.box = "generic/ubuntu2204"
    ubuntu22.vm.hostname = "ubuntu22"
    ubuntu22.vm.network :private_network, ip: "10.0.0.11"
    ubuntu22.vm.provision "shell", path: "./scripts/install-minion.sh", args: ["10.10.28.69", "ubuntu22"]
  end
  
end
