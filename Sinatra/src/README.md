```bash
docker build -t integralist/sinatra:v3 .
docker images
docker run -p 49161:4567 -d integralist/sinatra:v3
docker ps
docker logs {container_id}
curl -i $(boot2docker ip):49161
```
