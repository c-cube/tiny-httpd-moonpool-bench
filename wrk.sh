#!/bin/sh

PORT=8084
wrk -c 800 -d 10s -t 40 --latency "http://localhost:$PORT/hello/world"
