#!/bin/bash 

SERVER=127.0.0.1
NUM=1000
CONCURRENT=2
maxSockets=100
DELAY=5
POST=/post

node sleep_server.js &

sleep_server_pid=$!

# node proxy.js $maxSockets $SERVER 1984 1986 &
node proxy.js $maxSockets $SERVER 1984 1985 &

sleep 1

node -v
echo "$maxSockets maxSockets, $CONCURRENT concurrent, $NUM requests per concurrent, ${DELAY}ms delay"

echo "keep alive"
echo "siege -c $CONCURRENT -r $NUM -d 2 http://localhost:1985${POST}/k/$DELAY"
siege -c $CONCURRENT -r $NUM -d 1 http://localhost:1985${POST}/k/$DELAY

sleep 5

echo "normal"
echo "siege -c $CONCURRENT -r $NUM -d 2 http://localhost:1985${POST}/$DELAY"
siege -c $CONCURRENT -r $NUM -d 2 http://localhost:1985${POST}/$DELAY

sleep 3

kill $sleep_server_pid
kill %
kill %