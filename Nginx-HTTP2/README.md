## Certificates

Run `sh setup-certs.sh`

The CA details entered should be something like...

```
Country Name: UK
Organization Name: TheCA
Common Name: The CA
Email Address: ca@theca.com
```

The CSR details entered should be something like...

```
Country Name: UK
Organization Name: Integralist
Common Name: integralist.com
Email Address: mark@integralist.com
```

Which should result in a certificate with:

```
subject=/C=UK/O=Integralist/CN=integralist.com/emailAddress=mark@integralist.com
```

## Building

- `docker build -t my-ruby-app ./docker-app`

## Running

Run the Ruby app:

```bash
docker run --name ruby-app -p 4567:4567 -d my-ruby-app
```

> Note: this will be accessible via http://&lt;docker_ip&gt;:4567/

Run nginx (using latest/standard nginx container):

```bash
docker run --name nginx-container \
  -v $(pwd)/docker-nginx/certs/server.crt:/etc/nginx/certs/server.crt \
  -v $(pwd)/docker-nginx/certs/server.key:/etc/nginx/certs/server.key \
  -v $(pwd)/docker-nginx/certs/ca.crt:/etc/nginx/certs/ca.crt \
  -v $(pwd)/docker-nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  --link ruby-app:app \
  -p 60080:80 \
  -p 60443:443 \
  -d nginx
```

> Note: I switched to using explicit ports (`-p`) from dynamic ports (`-P`) because nginx needed access to the port for redirecting HTTP to HTTPS, but it seems A.) that didn't work and B.) there is no other easy solution (see https://github.com/docker/docker/issues/3778)

Curl the service endpoint:

```bash
export dev_ip=$(docker-machine ip dev)
export dev_pt=$(docker port nginx-container 443 | awk -F ':' '{ print $2 }')

curl --insecure https://$dev_ip:$dev_pt/app/
curl --insecure https://$dev_ip:$dev_pt/app/foo
```

## View in browser

There are two issues visting the above service endpoint via the browser:

1. The domain doesn't match the certificate
2. The certificate isn't verified/trusted

The first problem we can solve locally by opening up `/etc/hosts` and adding `192.168.99.100 integralist.com` (the ip might be different for you, but that ip is effectively the result of running `docker-machine ip dev`). You can now access the service endpoint via `https://integralist.com:32772/app/foo`

The second problem is solved by `curl` using the `--insecure` flag and in the browser you either ignore the 'warning' presented, OR you can add the certificate to your operating system's certificate keychain (so it knows the issuing CA is trusted).

## Debugging

```
docker exec -it nginx-container bash
```
