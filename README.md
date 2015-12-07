docker-microservice
===================

docker-microservice is a configurable simulation microservice that can be used to simulate actual microservice networks.
docker-microservice is available in Docker Hub under afein/service

The init_cluster.sh script creates a docker swarm cluster with an overlay network using the virtualbox driver.

The `deploy_service.sh service_name node_name` script deploys an instance of docker-microservice using a specific name to a target node


The input to each microservice determines the probabilistic path that will be called in the microservice network
