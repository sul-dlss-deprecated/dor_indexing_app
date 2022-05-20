#!/bin/sh

# This is a utility that waits for a port to be accessable. It depends on netcat (nc)
# Example:
#   ./wait-port.sh localhost 8080
#
while ! nc -z $1 $2 ; do
  sleep 1 ;
  echo waiting for $1:$2
done
