```bash
docker build -t integralist/sinatra:v2 .
docker images
docker run -p 49161:4567 -d integralist/sintra:v2
docker ps
docker logs {container_id}
curl -i $(boot2docker ip):49161
```
