```bash
cd src
docker build -t integralist/nodejs .
docker images
docker run -p 49160:8080 -d integralist/nodejs
docker ps
docker logs {container_id}
curl -i http://localhost:49160
```
