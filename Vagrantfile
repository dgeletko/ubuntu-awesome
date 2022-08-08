# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/ubuntu-20.04"
    config.vm.provider "virtualbox" do |vbox|
        vbox.name = "ubuntu_awesome"
        vbox.gui = true
        vbox.cpus = 1
        vbox.memory = "2048"
        vbox.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        vbox.customize ["modifyvm", :id, "--vram", 64]
        vbox.customize ["storageattach", :id,
                        "--storagectl", "IDE Controller",
                        "--port", "0",
                        "--device", "1",
                        "--type", "dvddrive",
                        "--medium", "emptydrive"]
    end

    config.vm.provision "ansible_local" do |ansible|
        ansible.inventory_path = "hosts"
        ansible.limit = "localhost"
        ansible.playbook = "awesome.yml"
        ansible.extra_vars = {
            user: "awesome",
            vagrant: true
        }
    end
end

