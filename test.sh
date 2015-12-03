#!/bin/bash
curl -X POST $1 --data '{"requestID": 0, "process":[3, 5, 5], "block": [1, 10, 5], "path": [{"movie-service": 1}, {"image-service": 1}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[2, 5], "block": [1, 10], "path": [{"rating-service": 0.5, "image-service":0.5}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[2, 5], "block": [1, 10], "path": [{"rating-service": 0.5, "image-service":0.5}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[2, 5], "block": [1, 10], "path": [{"rating-service": 0.5, "image-service":0.5}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[2, 5], "block": [1, 10], "path": [{"rating-service": 0.5, "image-service":0.5}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[2, 5], "block": [1, 10], "path": [{"rating-service": 0.5, "image-service":0.5}], "visited":[]}'
curl -X POST $1 --data '{"requestID": 0, "process":[3, 5, 5], "block": [1, 10, 5], "path": [{"movie-service": 1}, {"image-service": 1}], "visited":[]}'

docker-machine scp swarm-m:/var/log/micro ./logs
