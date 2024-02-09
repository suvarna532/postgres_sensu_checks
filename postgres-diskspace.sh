#! /bin/bash

HELP="
    usage: $0 [ -w value -c value ]

        -w --> Warning percentage for Disk Space
        -c --> Critical percentage for Disk Space
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"    
else 
    while [ -n "${1}" ]; do
        case "${1}" in
            -w | --warning-percentage)
                w_disk="${2}"
                shift
                shift
                ;;
            -c | --critical-percentage)
                c_disk="${2}"
                shift
                shift
                ;;
        esac
    done

    if [ -z "${c_disk}" -o -z "${w_disk}" ]; then
        status="${HELP}"
        message_string="Both critical and warning thresholds must be defined"
        status_code=1
    else
        
        used_disk_space=$(df -h | grep /dev/sdb | awk '{print $5}')
        used_disk_percentage=$(echo "scale=2; $used_disk_space" | bc -l)

        if (( $(echo "$used_disk_percentage > $c_disk" | bc -l) )); then
            status="CRITICAL"
            message_string="Postgres disk space is above critical limit $used_disk_percentage %"
            status_code=2
        elif (( $(echo "$used_disk_percentage > $w_disk" | bc -l) )); then
            status="WARNING"
            message_string="Postgres disk space is above warning limit $used_disk_percentage %"
            status_code=1
        else
            status="OK"
            message_string="Postgres disk space usage $used_disk_percentage % is below the defined limits"
            status_code=0
        fi
    fi

    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi
