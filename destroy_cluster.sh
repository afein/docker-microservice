#!/bin/bash

eval $(docker-machine env --swarm swarm-m)
docker-machine rm $(docker-machine ls -q)
docker network rm cluster
