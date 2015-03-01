# Docker

- [Introduction](#introduction)
- [Exposing the Docker daemon](#exposing-the-docker-daemon)
- [Help with Docker commands](#help-with-docker-commands)
- [CMD vs ENTRYPOINT](#cmd-vs-entrypoint)
- [Alternative CoreOS/Vagrantfile](#alternative-coreosvagrantfile)
- [Example Docker Containers](#example-docker-containers)
- [VMWare Provider](#vmware-provider)

## Introduction

Getting Docker set-up on a non-Linux environment (such as a Mac) can be done in a few ways; below are a few popular options:

1. Use Docker's "Boot2Docker" VM (uses VirtualBox to set-up the VM)
2. Use a CoreOS VM via Vagrant (with some modifications, such as exposing a private ip)

We're going to use the latter option. The host will attempt to connect directly to the VM's private ip (although, as we'll see in the next section, the Docker daemon needs to be exposed too for that to happen).

## Exposing the Docker daemon

> UPDATE: the Vagrantfile executes a `provision.sh` which automates all of the below steps for you

If you just do a `vagrant up` and try to run a Docker command (such as `docker ps`) then you'll get an error, like: `Cannot connect to the Docker daemon. Is 'docker -d' running on this host?`.

For the host to be able to use the Docker CLI, the Docker daemon on CoreOS needs to be exposed via a TCP port (as we're setting an ip address to access the CLI like so: `export DOCKER_HOST=tcp://172.17.8.100:2375`).

The following are the steps required to do this:

Add `export DOCKER_HOST=tcp://172.17.8.100:2375` to your `.zshrc` (or `.bashrc`) configuration file (as per the private ip defined inside the CoreOS Vagrantfile).

Read: http://coreos.com/docs/launching-containers/building/customizing-docker/ but effectively the steps are:

- `vagrant up`
- `vagrant ssh`
- `sudo touch /etc/systemd/system/docker-tcp.socket`
- Add following content into above socket file:

```
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=2375
Service=docker.service
BindIPv6Only=both

[Install]
WantedBy=sockets.target
```

- `sudo systemctl enable docker-tcp.socket`
- `sudo systemctl stop docker`
- `sudo systemctl start docker-tcp.socket`
- `sudo systemctl start docker`
- `exit`
- `docker ps`

> Note: if you're using Ubuntu and not CoreOS then see https://github.com/Integralist/Linux-and-Docker-Development-Environment/blob/master/provision.sh#L49-L55 for example of exposing the Docker daemon ip

## Help with Docker commands

- `docker help` lists all commands
- `docker help [command]` lists all options for specified command

## CMD vs ENTRYPOINT

http://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile

Effectively, Docker has a default `ENTRYPOINT` which is `/bin/sh -c`. 

A typical Docker command will look like (where, for example `{COMMAND}` is `bash`):

`docker run -i -t {IMAGE_NAME} {COMMAND}` 

e.g. `docker run -i -t MY_IMAGE bash`

In the above example you're passing the command `bash` to the default `ENTRYPOINT` (`/bin/sh -c`) which would drop us into a Bash shell ready to execute some more commands within the Docker container.

In the `Dockerfile` you can change the `ENTRYPOINT` to be something else, so you could change it to be the `cat` command instead of `sh` (e.g. `ENTRYPOINT ["/bin/cat"]`). 

If you did that for your Docker container then you could pass in a "command" to the container like so:

`docker run -i -t MY_IMAGE /etc/passwd` which would pass the command `/etc/passwd` to the `cat` command

> You can also override the ENTRYPOINT via the command-line using the `--entrypoint` flag:  
`docker run --rm -it --entrypoint=/bin/bash my_image`

## Alternative CoreOS/Vagrantfile

The following is a simplified `Vagrantfile`. It's similiar but minus the comments and also doesn't work-around everything that the `Vagrantfile` within this repo caters for:

```rb
Vagrant.configure('2') do |config|
  config.vm.box = "coreos"
  config.vm.box_url = "http://storage.core-os.net/coreos/amd64-generic/dev-channel/coreos_production_vagrant.box"
  config.vm.network "private_network",  ip: "172.17.8.100"
  config.vm.synced_folder ".", "/home/core/share",
    id: "core",
    :nfs => true,
    :mount_options => ['nolock,vers=3,udp']
end
```

## Example Docker Containers

This repository has basic Dockerfiles for both NodeJS and Ruby Sinatra applications. To build the containers please read the instructions for each container.

## VMWare Provider

If you're using VMWare as your provider (e.g. `vagrant up --provider=vmware_fusion`) then you might run into an issue mounting your folders into the CoreOS VM.

The error might look something like the following...

```
Bringing machine 'default' up with 'vmware_fusion' provider...
==> default: Cloning VMware VM: 'coreos-alpha'. This can take some time...
==> default: Checking if box 'coreos-alpha' is up to date...
==> default: Verifying vmnet devices are healthy...
==> default: Preparing network adapters...
==> default: Fixed port collision for 22 => 2222. Now on port 2200.
==> default: Starting the VMware VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 172.16.82.134:22
    default: SSH username: core
    default: SSH auth method: private key
==> default: Machine booted and ready!
==> default: Forwarding ports...
    default: -- 22 => 2200
==> default: Setting hostname...
==> default: Configuring network adapters within the VM...
==> default: Exporting NFS shared folders...
==> default: Preparing to edit /etc/exports. Administrator privileges will be required...
==> default: Mounting NFS shared folders...
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

mount -o 'nolock,vers=3,udp' 172.17.8.1:'/Users/foobar/path/to/current/directory' /home/core/share

Stdout from the command:



Stderr from the command:

mount.nfs: access denied by server while mounting 172.17.8.1:/Users/foobar/path/to/current/directory
```

It turns out this might be an issue with CoreOS not assigning the private "host-only" network ip address properly: https://github.com/coreos/coreos-vagrant/issues/159#issuecomment-54267821

If you were to `vagrant ssh` onto the box and run `ifconfig` you would notice the ip address assigned is not the one requested in the `Vagrantfile`. But if you then checked the CoreOS network settings (run `cat /etc/systemd/network/50-vagrant1.network`) then you'll see that the ip address listed matches what is defined inside our `Vagrantfile`.

### Work around

To work around this issue (temporarily, until an official fix is found) I would suggest running through the following steps:

#### Host machine (i.e. your Mac)

- Run `sudo vim /etc/exports/` and edit the relevant command so that the ip address (the one that matches what's defined in the `Vagrantfile`) is removed -> this means the VM makes the mount available to all users
- Run `sudo nfsd restart`

#### CoreOS VM

- `sudo mount -o 'nolock,vers=3,udp' 172.17.8.1:'/Users/foo/path/to/directory' /home/core/share` (make sure to change `/Users/foo/path/to/directory` to your directory -> you can get this command out of the failed `vagrant up` output)
