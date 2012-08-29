#!/bin/bash 

sudo sysctl -w net.inet.ip.portrange.first=12000
sudo sysctl -w net.inet.tcp.msl=1000
sudo sysctl -w kern.maxfiles=1000000 kern.maxfilesperproc=1000000
sudo ulimit -n 100000

sysctl -n machdep.cpu.brand_string

SERVER=127.0.0.1
NUM=1000
CONCURRENT=1
maxSockets=50
DELAY=5
POST=/post

node sleep_server.js &

sleep_server_pid=$!

node proxy.js $maxSockets $SERVER &

sleep 1

node -v
echo "$maxSockets maxSockets, $CONCURRENT concurrent, $NUM requests per concurrent, ${DELAY}ms delay"

netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

echo "keep alive"
echo "siege -c $CONCURRENT -r $NUM -b http://localhost:1985${POST}/k/$DELAY"
siege -c $CONCURRENT -r $NUM -b http://localhost:1985${POST}/k/$DELAY

netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

sleep 5

netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

echo "normal"
echo "siege -c $CONCURRENT -r $NUM -b http://localhost:1985${POST}/$DELAY"
siege -c $CONCURRENT -r $NUM -b http://localhost:1985${POST}/$DELAY

netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

sleep 3

kill $sleep_server_pid
kill %