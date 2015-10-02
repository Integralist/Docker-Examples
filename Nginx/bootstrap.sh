#!/bin/bash

docker build -t my-ruby-app ./docker-app
docker build -t my-nginx ./docker-nginx
docker run --name ruby-app -p 4567:4567 -d my-ruby-app
docker run --name nginx-container \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/docker-nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  --link ruby-app:app \
  -P -d my-nginx
curl http://$(docker-machine ip dev):32769/
curl http://$(docker-machine ip dev):32769/test.html
curl http://$(docker-machine ip dev):32769/app/
curl http://$(docker-machine ip dev):32769/app/foo
