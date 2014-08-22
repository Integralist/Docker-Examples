$update_channel = "alpha"

Vagrant.configure("2") do |config|

  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # Plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.hostname = "coreos-%s" % $update_channel

  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  # 172 is a private network range (we add this in ~/.zshrc like so: `export DOCKER_HOST=tcp://172.17.8.100:2375`)
  config.vm.network :private_network, ip: "172.17.8.100"

  # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
  config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

end
