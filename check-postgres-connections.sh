#! /bin/bash

HELP="
    usage: $0 [ -W value -C value -U username -w password ]

        -W --> Warning value < number of available connections
        -C --> Critical value < number of available connections
        -U --> Postgres Username < default username: postgres)
        -w --> Postgres password < default password postgres)
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"   
else 
    default_username="postgres"
    default_password="postgres"

    while [ -n "${1}" ]; do
        case "${1}" in
            -W | --warning-count)
                w_count="${2}"
                shift
                shift
                ;;
            -C | --critical-count)
                c_count="${2}"
                shift
                shift
                ;;
            -U | --username)
                username="${2}"
                shift
                shift
                ;;
            -w | --no-password)
                password="${2}"
                shift
                shift
                ;;
        esac
    done
    if [ -z "${username}" ]; then
        username="${default_username}"
    fi

    if [ -z "${password}" ]; then
        password="${default_password}"
    fi
    if [ -z "${c_count}" -o -z "${w_count}" ]; then
        status="${HELP}"
        message_string="Both critical and warning thresholds must be defined"
        status_code=1
    else
        connection_check="$(psql -U "$username" -w "$password" -c '\x' -c 'SELECT version();')"
        if [ $? -ge 1 ]; then
            status="Connection ERROR"
            message_string="$connection_check"
            status_code=1
        else
            max_connections="$(psql -U "$username" -w "$password" -c '\x' -c 'SHOW max_connections' | awk '/max_connections/ {print $3}')"
            superuser_connections="$(psql -U "$username" -w "$password" -c '\x' -c 'SHOW superuser_reserved_connections' | awk '/superuser_reserved_connections/ {print $3}')"
            available_connections="$(echo "$max_connections-$superuser_connections" | bc -l | tr -d '\r')"

            if [ "$available_connections" -le "$c_count" ]; then
                status="CRITICAL"
                message_string="Only $available_connections connections left available on Postgres"
                status_code=1
            elif [ "$available_connections" -le "$w_count" ]; then
                status="WARNING"
                message_string="Only $available_connections connections left available on Postgres"
                status_code=2
            else
                status="OK"
                message_string="There are $available_connections connections available on Postgres"
                status_code=0
            fi
        fi
    fi
    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi    
