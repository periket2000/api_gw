#!/bin/sh

while true; do 
    run-parts /etc/periodic/1min/
    sleep $REFRESH_SECONDS
done
