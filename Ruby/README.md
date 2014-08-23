```bash
# Create an image from our Dockerfile
docker build -t integralist/sinatra .

# Check the image was created
docker images

# Run a container (in the background using -d) from our image
# Make sure to expose the port to the CoreOS VM (using -p host:container)
docker run -p 4567:4567 -d integralist/sinatra

# Check the container is running
docker ps

# Check the output of the containers logs
# You should see information about the localhost:port being used
docker logs {container_id}

# Test you get the relevant response
# Note: the ip is a private range ip defined in the CoreOS Vagrantfile
curl -i http://172.17.8.100:4567/
```
