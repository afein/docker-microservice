from flask import Flask, request
import os
import time
import random
import requests

app = Flask("microservice")

os.system("mkdir -p /var/log/micro")
log = open("/var/log/micro/microservice.log", "w+")

requestID_counter = 1

service_name = os.environ["SERVICE_NAME"]

def busy_wait(seconds):
    dt = time.strptime(str(seconds), "%S")
    now = time.time()
    while time.time() < now + seconds:
        pass

'''
    POST: the body must be a JSON-formatted object:

        {
            "requestID" : 15 // 0 if first request
            "process" : [10, 5, 2, 10], // processing time spent by each service in seconds
            "block" : [10, 0, 2, 2] // sleeping time spent by the service in seconds
            "path": [
                { "microA" : 0.8,
                  "microB" : 0.2
                },
                {
                  "microC" : 0.5,
                  "microA" : 0.5
                }
            ],
            "visited" : ["micro0"]
'''

@app.route("/", methods=["POST"])
def handle():
    global requestID_counter

    if request.method == "POST":
        obj = request.get_json(force=True)
        if "requestID" not in obj or \
           "process" not in obj or \
           "block" not in obj or \
           "path" not in obj or \
           "visited" not in obj:
            abort(400, "Invalid Request")

        if len(obj["process"]) != 1 and len(obj["process"]) == len(obj["block"]):
            abort(400, "Could not determine length of call path")

        # TODO: log request
        #
        if service_name in obj["visited"]:
            return "OK"

        process = obj["process"].pop(0)
        block = obj["block"].pop(0)

        # perform processing and blocking
        busy_wait(obj["process"])
        sleep(obj["block"])

        # Handle having no further targets
        if len(obj[path]) == 0:
            return "OK"

        # Build response
        resp = {}
        if obj["requestID"] == 0:
            resp["requestID"] = requestID_counter
            # TODO: use distributed requestID counter for multiple entrypoints
            requestID_counter += 1
        else:
            resp["requestID"] = obj["requestID"]
        resp["process"] = obj["process"]
        resp["block"] = obj["block"]
        resp["visited"] = [obj["block"]] + [service_name]
        if len(obj["path"] == 1):
            resp["path"] = []
        else:
            resp["path"] = obj["path"][1:]
        
        # Determine next microservice to call
        targets = obj["path"].pop(0)
        total_prob = 0
        roll = random.random()
        for target, prob in targets:
            total_prob += prob
            if target == service_name:
                continue
            if roll < total_prob:
                final_target = target

        # Send POST to final target
        requests.post("http://" + final_target +".swarm, json=resp)
        return "OK"

app.run(host="0.0.0.0", port=80)
