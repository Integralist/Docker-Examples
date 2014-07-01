# Docker

Add `export DOCKER_HOST=tcp://0.0.0.0:2375` to your `.zshrc` (or `.bashrc`) configuration file.

Read: http://coreos.com/docs/launching-containers/building/customizing-docker/ but effectively the steps are:

1. `vagrant up`
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
- `docker -H tcp://127.0.0.1:2375 ps` (although if you did the above `export` command, then just `docker ps`)
