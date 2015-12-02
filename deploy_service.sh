#!/bin/bash


if [ $# -eq 0 ]
then
	echo "First argument must be the service name"
	exit 1
fi

eval $(docker-machine env --swarm swarm-m)


master=$(docker-machine ip swarm-m)
if [ $# -eq 1 ]
then
	docker run -d -P -e SERVICE_NAME=$1 --dns $master afein/service
	exit 0
fi
docker run -d -P -e SERVICE_NAME=$1 -e constraint:node==$2 --dns $master --name $1 afein/service
