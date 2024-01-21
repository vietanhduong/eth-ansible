Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.box_check_update = false
  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.define "node1" do |instance|
    instance.vm.box = "ubuntu/jammy64"
    instance.vm.network "forwarded_port", guest: 22, host: 2200
    instance.vm.network "forwarded_port", guest: 80, host: 10080
  end

  config.vm.define "node2" do |instance|
    instance.vm.box = "ubuntu/jammy64"
    instance.vm.network "forwarded_port", guest: 22, host: 2201
    instance.vm.network "forwarded_port", guest: 80, host: 20080
  end
end
