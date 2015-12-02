#!/bin/bash
if [ $# -eq 0 ]
then
	echo "First argument must be number of slave nodes"
	exit 1
fi

echo -e "\e[34m Created Swarm Token:\e[0m"
TOKEN=$(docker run --rm swarm create)
echo $TOKEN
echo -e "\e[34m Creating Swarm Master Node\e[0m"
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery token://$TOKEN swarm-m
for i in `seq 1 $1`; do 
	echo -e "\e[34m Creating Swarm Slave Node $i\e[0m"
	docker-machine create -d virtualbox --swarm --swarm-discovery token://$TOKEN swarm-$i
done

sleep 5

eval $(docker-machine env --swarm swarm-m)

echo -e "\e[34m Starting DNS discovery on Master\e[0m"
docker run -d --restart=always  \
	--link=swarm-agent-master:swarm \
	-v /var/lib/boot2docker/ca.pem:/certs/ca.pem \
	-v /var/lib/boot2docker/server.pem:/certs/cert.pem \
	-v /var/lib/boot2docker/server-key.pem:/certs/key.pem \
	-p 53:53/udp \
	-e constraint:node==swarm-m \
	ahmet/wagl \
	wagl --swarm tcp://swarm:3376 \
	--swarm-cert-path /certs


echo -e "\e[34m Done! Docker info:\e[0m"
docker info
