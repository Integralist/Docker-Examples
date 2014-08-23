# Build from...
FROM ubuntu:14.04
MAINTAINER Mark McDonnell <mark.mcdx@gmail.com>

# Install Ruby and Sinatra
RUN apt-get -qq update
RUN apt-get -qqy install ruby ruby-dev
RUN gem install sinatra

# Note:
# We have a Gemfile that specifies Sinatra as a dependency,
# so we probably should only install Ruby and change to `gem install bundler`
# Then we could avoid using ENTRYPOINT and use CMD to construct a command like:
# `bundle install && ruby /src/app.rb`

# Add our current directory into the /src directory of the container
ADD ./src /ruby-app

# Make sure to expose the port so we can access the application outside of the VM
EXPOSE 4567

ENTRYPOINT ["ruby", "/ruby-app/app.rb"]
