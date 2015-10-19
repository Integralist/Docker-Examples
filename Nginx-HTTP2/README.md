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
  -P -d nginx
```

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

## HTTP to HTTPS Redirection

The nginx configuration will attempt to redirect HTTP traffic to HTTPS using a 301 redirect. This works, but be careful you recognise that Docker provides a different port number for HTTP `:80` compared to HTTPS `:443` (run `docker ps` to verify this).

So if I was to go to my browser and type:

```
http://integralist.com:32783/app/
```

I would be redirected automatically to:

```
https://integralist.com:32782/app/
```

> Notice the protocol changes to HTTPS and the port number updates as well

The only oddity is that in the browser it ends up downloading a file called `download` and this file seems to contain a single line of encoded content? So when using `curl` we find things don't work...

```bash
export dev_ip=$(docker-machine ip dev)
export dev_80=$(docker port nginx-container 80 | awk -F ':' '{ print $2 }')
export dev_443=$(docker port nginx-container 443 | awk -F ':' '{ print $2 }')

# The following commands work, as they hit HTTPS...

curl --insecure https://$dev_ip:$dev_443/app/
curl --insecure https://$dev_ip:$dev_443/app/foo

# The following commands don't work as the file download prevents HTTP redirection?

curl --insecure http://$dev_ip:$dev_80/app/
curl --insecure http://$dev_ip:$dev_80/app/foo
```

## Debugging

```
docker exec -it nginx-container bash
```
