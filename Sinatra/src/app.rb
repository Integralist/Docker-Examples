require 'sinatra'

# Bind to ALL device interfaces
# This is so app localhost can be accessed outside a Docker container
set :bind, '0.0.0.0'

get '/' do
  'Hello World'
end
