#! /bin/bash

HELP="
    usage: $0 [ -w value -c value ]

        -w --> Warning percentage < value
        -c --> Critical percentage < value
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"    
else 
    default_username="postgres"
    default_password="postgres"

    while [ -n "${1}" ]; do
        case "${1}" in
            -w | --warning-percentage)
                w_memory="${2}"
                shift
                shift
                ;;
            -c | --critical-percentage)
                c_memory="${2}"
                shift
                shift
                ;;
        esac
    done

    if [ -z "${c_memory}" -o -z "${w_memory}" ]; then
        status="${HELP}"
        message_string="Both critical and warning thresholds must be defined"
        status_code=1
    else
        used_memory="$(ps aux | grep postgres | head -1 | awk '{print $4}')"
        if (( $(echo "$used_memory > $c_memory" |bc -l) )); then
            status="CRITICAL"
            message_string="Postgres memory is above critical limit $used_memory %"
            status_code=2
        elif (( $(echo "$used_memory > $w_memory" |bc -l) )); then
            status="WARNING"
            message_string="Postgres memory is above warning limit $used_memory %"
            status_code=1
        else
            status="OK"
            message_string="Postgres memory usage $used_memory % is below the defined limits"
            status_code=0
        fi
    fi

    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi
