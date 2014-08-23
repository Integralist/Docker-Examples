```bash
cd src
docker build -t integralist/sinatra:v3 .
docker images
docker run -p 4567:4567 -d integralist/sinatra:v3
docker ps
docker logs {container_id}
curl -i http://localhost:4567
```
