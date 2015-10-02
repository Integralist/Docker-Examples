#!/bin/bash

# Create the CA Key and Certificate for signing Client Certs
# Just enter `pass` for the passphrase (doesn't matter as this isn't something you'd use in production)
# For the ca.crt generation I pretty much entered . (which means 'no value') for all details
# Only exception was the 'Common Name' field which I entered 'My Cool CA' (so I recognise it as the 'ca')
openssl genrsa -des3 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt

# Create the Server Key, CSR, and Certificate
# Notice I don't specify -des3 as I don't want a passphrase
# For the CSR I pretty much entered . (which means 'no value') for all details
# Only exception was the 'Common Name' field which I entered 'Integralist' (so I recognise it as the 'server')
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr

# We're self signing our own server cert here. This is a no-no in production.
# Just need to enter `pass` for the CA key access
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# Create the Client Key and CSR
# Notice I don't specify -des3 as I don't want a passphrase
# I've made the encryption length 2048 instead of 4096 as a speed/perf compromise
# For the CSR I pretty much entered . (which means 'no value') for all details
# Only exception was the 'Common Name' field which I entered 'Mark McDonnell' (so I recognise it as the 'client')
# The other exception was the 'Email Address' field, as I want to parse out the email in my Ruby application
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr

# Sign the client certificate with our CA cert. Unlike signing our own server cert, this is what we want to do.
# Just need to enter `pass` for the CA key access
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
