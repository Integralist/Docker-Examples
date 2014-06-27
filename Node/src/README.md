```bash
docker build -t integralist/nodejs .
docker images
docker run -p 49160:8080 -d integralist/nodejs
docker ps
docker logs {container_id}
curl -i $(boot2docker ip):49160
```
