#!/bin/bash

docker service create \
  --mode replicated \
  --replicas 1 \
  --name haproxy-service \
  --network app-net \
  --publish published=80,target=80,protocol=tcp,mode=ingress \
  --publish published=443,target=443,protocol=tcp,mode=ingress \
  --mount type=bind,src=./,dst=/usr/local/etc/haproxy/,ro=true \
  --dns=127.0.0.11 \
  haproxytech/haproxy-debian:2.0

