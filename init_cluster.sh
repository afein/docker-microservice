#!/bin/bash
if [ $# -eq 0 ]
then
	echo "First argument must be number of slave nodes"
fi

TOKEN=$(docker run --rm swarm create)
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery token://$TOKEN swarm-m && \
	  for i in {0..$1}; do docker-machine create -d virtualbox --swarm --swarm-discovery token://$TOKEN swarm-$i; done

docker run -d --restart=always  \
	--link=swarm-agent-master:swarm \
	-v /var/lib/boot2docker/ca.pem:/certs/ca.pem \
	-v /var/lib/boot2docker/server.pem:/certs/cert.pem \
	-v /var/lib/boot2docker/server-key.pem:/certs/key.pem \
	-p 53:53/udp \
	--name=dns \
	-e constraint:node==swarm-m
	ahmet/wagl \
	wagl --swarm tcp://swarm:3376 \
	--swarm-cert-path /certs

eval $(docker-machine env --swarm swarm-m)

docker info
