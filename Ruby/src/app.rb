require 'sinatra'

# Bind to ALL device interfaces
# This is so app localhost can be accessed outside a Docker container
# So although in the Dockerfile we expose port 4567 to the host machine
# we're not exposing the VM's localhost unless we set the application to
# bind to all the available interfaces
set :bind, '0.0.0.0'

get '/' do
  'Hello World (from Ruby)'
end
