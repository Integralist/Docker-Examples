Make sure all the following commands are run from this project's root directory.

Build the Docker images:

```bash
docker build -t my-ruby-app ./docker-app
docker build -t my-nginx ./docker-nginx
```

Run the Docker containers:

```bash
docker run --name ruby-app -p 4567:4567 -d my-ruby-app
docker run --name nginx-container \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -v $(pwd)/docker-nginx/certs:/etc/nginx/certs/ \
  -v $(pwd)/docker-nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  --link ruby-app:app \
  -P -d my-nginx
```

Test the application is accessible via HTTPS:

> Note: `<nginx_port>` can be found by running `docker ps`

```bash
# Should error as HTTP used instead of HTTPS (nginx is setup to only listen on 443 not 80)
curl http://$(docker-machine ip dev):<nginx_port>/

# Should error as server's cert isn't trusted (i.e. it's self-signed)
curl https://$(docker-machine ip dev):<nginx_port>/

# We can use --insecure to trust the self-signed certificate

# Should show an error as no client certificate provided
curl --insecure https://$(docker-machine ip dev):<nginx_port>/

# Define some local variables for client cert location
client_key=$(pwd)/docker-nginx/certs/client.key
client_crt=$(pwd)/docker-nginx/certs/client.crt

# Following curl's should work as client cert are provided as flags
# Make sure to change <nginx_port> to whatever Docker has exposed it as
curl --insecure --key $client_key --cert $client_crt https://$(docker-machine ip dev):<nginx_port>/
curl --insecure --key $client_key --cert $client_crt https://$(docker-machine ip dev):<nginx_port>/test.html
curl --insecure --key $client_key --cert $client_crt https://$(docker-machine ip dev):<nginx_port>/app/
curl --insecure --key $client_key --cert $client_crt https://$(docker-machine ip dev):<nginx_port>/app/foo

# Finally, let's test the client cert is being proxied through the HTTP request to the Ruby app:
curl --insecure --key $client_key --cert $client_crt https://$(docker-machine ip dev):<nginx_port>/app/cert
```

If you get an error, such as:

```
curl: (58) SSL: Can't load the certificate "/path/to/docker-nginx/certs/client.crt" and its private key: OSStatus -25299
```

Then this is because the `curl` command on Mac OSX is fucked. 

Use a Docker container instead, like so:

```bash
docker run \
  -it \
  -v $(pwd)/docker-nginx/certs:/var/cert \
  speg03/curl --insecure \
              --key /var/cert/client.key \
              --cert /var/cert/client.crt \
              https://$(docker-machine ip dev):$(docker port nginx-container 443 | awk -F ':' '{ print $2 }')/app/cert
```

You should see something like the following output by the Ruby application

```
/CN=Mark McDonnell/emailAddress=mark@integralist.com
```

Now at this point you can parse your client certificate's CommonName (CN) however you like. In my application I just print it back out to the user, but in a real-world application you might want to use the details to present some nice personalised welcome message like "Hello Mark!" or whatever.

Either way, you can only access the Ruby application if you provide a cert/key that was signed by the self-signed CA that is specified in the nginx configuration.

If you were to try and provide a different cert/key (one that wasn't signed by the self-signed CA), then you'll see the following error response:

```html
<html>
<head><title>400 The SSL certificate error</title></head>
<body bgcolor="white">
<center><h1>400 Bad Request</h1></center>
<center>The SSL certificate error</center>
<hr><center>nginx/1.4.6 (Ubuntu)</center>
</body>
</html>
```

Which is great. That is exactly what we want to see: denying access to our service unless properly authorised.
