$update_channel = "alpha"

Vagrant.configure("2") do |config|

  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = ">= 308.0.1"

  # Box URL (overridden for VMware)
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel
  config.vm.provider :vmware_fusion do |vb, override|
    override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $update_channel
  end

  # VirtualBox doesn't have guest additions (or a functional vboxsf) in CoreOS
  # So here we're helping Vagrant to be smarter with its configuration
  config.vm.provider :virtualbox do |v|
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # Resolve issue with a specific Vagrant plugin by preventing it from updating
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Sets a hostname for the VM
  config.vm.hostname = "coreos-%s" % $update_channel

  # Configure the VM's Memory and CPU allocation
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  # 172 is a private network range (we add this in ~/.zshrc like so: `export DOCKER_HOST=tcp://172.17.8.100:2375`)
  config.vm.network :private_network, ip: "172.17.8.100"

  # Enable NFS for sharing the host machine into the coreos-vagrant VM
  config.vm.synced_folder ".", "/home/core/share",
                          id: "core",
                          :nfs => true,
                          :mount_options => ['nolock,vers=3,udp']

  config.vm.provision "shell" do |s|
    s.privileged = true
    s.path = "provision.sh"
  end

end
