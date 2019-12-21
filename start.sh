#!/bin/bash

/usr/sbin/nginx -c /app/nginx.conf
while true; do /app/tides.pl > /app/index.html; sleep 5m; done
