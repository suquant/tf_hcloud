#!/bin/bash
set -e

usage() { echo "Usage: $0 -t <token> -i <ip address> -p <reverse dns> -s <server id>" 1>&2; exit 1; }

while getopts ":t:i:p:s:" o; do
    case "${o}" in
        t)
            token=${OPTARG}
            ;;
        i)
            ip=${OPTARG}
            ;;
        p)
            ptr=${OPTARG}
            ;;
        s)
            server=${OPTARG}
            ;;
        *)
            if [ -z "${token}" ] || [ -z "${ip}" ] || [ -z "${ptr}" ] || [ -z "${server}" ]; then
                usage
            fi
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${token}" ] || [ -z "${ip}" ] || [ -z "${ptr}" ] || [ -z "${server}" ]; then
    usage
fi

response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST \
            -H "Content-Type: application/json" -H "Authorization: Bearer ${token}"  \
            -d "{\"ip\":\"${ip}\",\"dns_ptr\":\"${ptr}\"}" \
                https://api.hetzner.cloud/v1/servers/${server}/actions/change_dns_ptr)
body=$(echo ${response} | sed -e 's/HTTPSTATUS\:.*//g')
status=$(echo ${response} | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ $status -lt 200 ] || [ $status -ge 300 ]; then
  echo "Error [HTTP status: $status]"
  echo $body
  exit 1
fi