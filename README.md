# Docker

- [Introduction](#introduction)
- [Exposing the Docker daemon](#exposing-the-docker-daemon)
- [Help with Docker commands](#help-with-docker-commands)
- [CMD vs ENTRYPOINT](#cmd-vs-entrypoint)

## Introduction

Getting Docker set-up on a non-Linux environment (such as a Mac) can be done in one of two ways:

1. Use Docker's "Boot2Docker" VM (which relies on Vagrant doing port forwarding)
2. Use a CoreOS VM (with some modifications, such as exposing a private ip)

We're going to use the latter option as it is much more reliable (and less confusing) than port forwarding (i.e. Docker exposes ports for the VM to access, and then the VM needs to expose ports to the Host). Instead, the host just connects directly to the VM's private ip (although, as we'll see, the Docker daemon needs to be exposed too).

## Exposing the Docker daemon

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

## Alternative CoreOS/Vagrantfile

```rb
Vagrant.configure('2') do |config|
  config.vm.box = "coreos"
  config.vm.box_url = "http://storage.core-os.net/coreos/amd64-generic/dev-channel/coreos_production_vagrant.box"
  config.vm.network "private_network",  ip: "172.12.8.150"
  config.vm.synced_folder ".", "/home/core/share",
    id: "core",
    :nfs => true,
    :mount_options => ['nolock,vers=3,udp']
end
```
