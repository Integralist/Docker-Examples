#!/usr/bin/env ruby

require "sinatra"

# Bind to ALL device interfaces
# This is so the application localhost can be accessed outside the Docker container
#
# So although in the Dockerfile we expose port 4567 to the host machine
# we're not exposing the Boot2Docker VM's localhost unless we set the application to
# bind to all the available interfaces
set :bind, "0.0.0.0"

configure { set :server, :puma }

class App < Sinatra::Base
  get "/" do
    return "Hello World"
  end

  get "/foo" do
    return "Foo!"
  end

  run! if app_file == $0
end
