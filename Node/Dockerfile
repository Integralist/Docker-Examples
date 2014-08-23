# Build from...
FROM centos:centos6

# Enable EPEL (Extra Packages for Enterprise Linux) for Node.js
# https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-rhel-centos-fedora-etc
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install Node.js and npm
RUN yum install -y nodejs npm --enablerepo=epel

# Bundle app source
ADD ./src /node-app

# Install app dependencies
RUN cd /node-app; npm install

# The app binds to port 8080 so we'll expose it
EXPOSE 8080

# CMD doesn't run at build time
# it is the intended command for the container when run with `docker run`
# if the user specifies arguments to `docker run` then they override the below CMD
CMD ["node", "/node-app/index.js"]
