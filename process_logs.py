import sys
import os
import time
import json

def parse_logs():
    # Parse_sleuth parses sleuth log messages to create the required messages of 
    # service_name, timestamp, service_class, workflow_id
    log_files = []
    for f in os.listdir(os.getcwd() + "/logs"):
        if f.endswith(".log"): 
            log_files.append((f, open(os.getcwd() + "/logs/" + f, 'r')))

    traces = {}
    trace_counter = 0

    result = []

    for filename, file in log_files:
        service_name = filename.split(".")[0]
        prev_stamp = 0
        for line in file:
            if "Request" not in line and "Response" not in line:
                continue

            # timestamps rounded to 10ms precision
            tokens = line.split(' ')
            epoch_stamp = float(tokens[0])

            type = "Response"
            if "Received" in line:
                type = "Request"

            json_idx = line.index("{")
            json_str = line[json_idx:]
            d = eval(json_str)
            
            # Convert trace_id to workflow id
            trace_id = d["requestID"]
            if trace_id not in traces:
                traces[trace_id] = trace_counter
                trace_counter += 1

            workflow_id = traces[trace_id]

            result.append({
                "Service" : service_name,
                "Timestamp" : epoch_stamp,
                "Workflow" : workflow_id,
                "Type" : type
            })

    return result


def group_by_workflow(intermediate):
    workflows = {}

    for entry in intermediate:
        if entry["Workflow"] not in workflows:
            workflows[entry["Workflow"]] = []
        workflows[entry["Workflow"]].append({
            "Service" : entry["Service"],
            "Type" : entry["Type"],
            "Timestamp" : entry["Timestamp"]
        })
    return workflows

def gen_latency(final):
    workflows = final
    res_workflows = {}

    for workflow_id, services in workflows.iteritems():
        last_timestamp = 0
        if workflow_id not in res_workflows:
            res_workflows[workflow_id] = []
        for service in services:
            if last_timestamp == 0:
                latency = 0
            else:
                latency = service["Timestamp"] - last_timestamp
            last_timestamp = service["Timestamp"]
            res_workflows[workflow_id].append({
                "Service" : service["Service"],
                "Type" : entry["Type"],
                "Latency" : latency
            })


def final_readable(final):
    for key, val in final.iteritems():
        print "-------------------"
        print "Workflow ID: " + str(key)
        for call in val:
            print "Service: " + call["Service"]
            print "Endpoint: " + call["Endpoint"]
            print "Latency: " + str(call["Latency"])
            print ""


if __name__ == "__main__":
    intermediate = parse_logs()
    f = open("intermediate_results", "w+")
    f.write(str(intermediate))

    final = group_by_workflow(intermediate)
    g = open("grouped_results", "w+")
    g.write(str(final))

#    final = group_by_workflow(intermediate)
#    g = open("grouped_results", "w+")
#    g.write(str(final))
#    final_readable(final)

