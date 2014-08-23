# DOCKER-VERSION 1.0.0
FROM centos:6.4

# Enable EPEL for Node.js
# https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#rhelcentosscientific-linux-6
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install Node.js and npm
RUN yum install -y npm

# Bundle app source
ADD . /src

# Install app dependencies
RUN cd /src; npm install

# The app binds to port 8080 so we'll expose it
EXPOSE 8080

# CMD doesn't run at build time 
# it is the intended command for the container when run with `docker run`
# if the user specifies arguments to `docker run` then they override the below CMD
CMD ["node", "/src/index.js"]
