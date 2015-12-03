#!/bin/bash
if [ $# -eq 0 ]
then
	echo "First argument must be number of slave nodes"
	exit 1
fi

echo -e "\e[34m Creating Key-Value store machine:\e[0m"
docker-machine create -d virtualbox mh-keystore

echo -e "\e[34m Deploying Consul:\e[0m"
docker $(docker-machine config mh-keystore) run -d \
	-p "8500:8500" \
	-h "consul" \
	progrium/consul -server -bootstrap

echo -e "\e[34m Creating Swarm Master Node\e[0m"
docker-machine create -d virtualbox --swarm --swarm-master  \
	--swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
	--engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
	--engine-opt="cluster-advertise=eth1:2376" \
	swarm-m

for i in `seq 1 $1`; do 
	echo -e "\e[34m Creating Swarm Slave Node $i\e[0m"
	docker-machine create -d virtualbox --swarm \
		--swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
		--engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
		--engine-opt="cluster-advertise=eth1:2376" \
	swarm-$i
done

sleep 5

eval $(docker-machine env --swarm swarm-m)

echo -e "\e[34m Starting Docker Network\e[0m"

docker network create --driver overlay cluster
docker network ls

echo -e "\e[34m Done! Docker info:\e[0m"
docker info
