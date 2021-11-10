#!/bin/bash
# If using network=host then this is a way to check if default ports are available for container
ports='55555 2222 8300 8301 8302 8741 8080 1943 55443 55556 8008 9000 9443 5671 1883 8883 8000 8443'
for port in $ports
do
echo Check $port
lsof -Pi :$port -sTCP:LISTEN
done
echo All ports scanned
