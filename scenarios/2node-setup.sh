#!/bin/bash
pushd ..

./deploy_service.sh api-gateway swarm-1
./deploy_service.sh rating-service swarm-1
./deploy_service.sh movie-service swarm-2
./deploy_service.sh image-service swarm-2

popd
