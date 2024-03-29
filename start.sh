#!/bin/bash
set -e

tmp_file='/app/tides.html.tmp'
prod_file='/app/tides.html'

/usr/sbin/nginx -c /app/nginx.conf

echo LOADING > "${prod_file}"
echo $(date +"%Y-%m-%dT%H:%M:%S%z") >> "${prod_file}"

while true;
do
    /app/tides.pl > "${tmp_file}";

    if [[ -s "${tmp_file}" ]]
    then
        ts=$(date +"%Y-%m-%dT%H:%M:%S%z")
        cat "${tmp_file}" > "${prod_file}"
	echo >> "${prod_file}"
        echo "UPDATED: ${ts}" >> "${prod_file}"
        rm -f "${tmp_file}"
    else
        echo 'ERROR: UNABLE TO UPDATE FORECAST'
        exit 1
    fi

    sleep 30m;
done
