#! /bin/bash

HELP="
    usage: $0 [ -w value -c value ]

        -w --> Warning percentage < value
        -c --> Critical percentage < value
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"    
else 
    while [ -n "${1}" ]; do
        case "${1}" in
            -w | --warning-percentage)
                w_cpu="${2}"
                shift
                shift
                ;;
            -c | --critical-percentage)
                c_cpu="${2}"
                shift
                shift
                ;;

        esac
    done

    if [ -z "${c_cpu}" -o -z "${w_cpu}" ]; then
        status="${HELP}"
        message_string="Both critical and warning thresholds must be defined"
        status_code=1
    else
        used_cpu="$(ps aux | grep postgres | head -1 | awk '{print $3}')"
        if (( $(echo "$used_cpu > $c_cpu" |bc -l) )); then
            status="CRITICAL"
            message_string="Postgres CPU is above critical limit $used_cpu %"
            status_code=2
        elif (( $(echo "$used_cpu > $w_cpu" |bc -l) )); then
            status="WARNING"
            message_string="Postgres CPU is above warning limit $used_cpu %"
            status_code=1
        else
            status="OK"
            message_string="Postgres CPU usage $used_cpu % is below the defined limits"
            status_code=0
        fi
    fi

    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi
