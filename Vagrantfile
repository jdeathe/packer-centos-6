# -*- mode: ruby -*-
# vi: set ft=ruby :

$box_version = "6.8.4"
$share_home = false
$vm_cpus = 1
$vm_gui = false
$vm_hostname = "centos-6.local"
$vm_memory = 512
$vm_name = "centos-6"

Vagrant.configure(2) do |config|
  config.vm.box = "jdeathe/centos-6"
  config.vm.box_version = $box_version
  # config.vm.box_url = "https://atlas.hashicorp.com/jdeathe/boxes/centos-6/versions/%s/providers/virtualbox.box" % $box_version
  # config.vm.box_url = "https://github.com/jdeathe/packer-centos-6/releases/download/%s/centos-6-virtualbox.box" % $box_version

  config.vm.define $vm_name
  config.vm.hostname = $vm_hostname

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Enable NFS shared home directory
  if $share_home
    config.vm.synced_folder \
      ENV['HOME'], 
      ENV['HOME'], 
      id: "home", 
      :nfs => true, 
      :mount_options => ["nolock","vers=3","udp"]
  end

  # VirtualBox Guest customisations
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = $vm_cpus
    vb.gui = $vm_gui
    vb.memory = $vm_memory
    vb.name = $vm_name
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", keep_color: true, name: "YUM Update", inline: "yum -y update"
  # config.vm.provision "shell", keep_color: true, name: "Install Apache", inline: "yum -y install httpd"
end
