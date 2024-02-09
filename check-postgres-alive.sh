#! /bin/bash

HELP="
    usage: $0 [ -U username -w password ]

        -U --> Username 
        -w --> password
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"    
else 
    default_username="postgres"
    default_password="postgres"

    while [ -n "${1}" ]; do
        case "${1}" in
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
    
    connection_check="$(psql -U "$username" -w "$password" -c '\x' -c 'SELECT version();')"
    if [ "$?" -eq 0 ]; then
        status="OK"
        message_string="Postgres is alive"
        status_code=0
    else
        status="CRITICAL"
        message_string="$connection_check"
        status_code=1

    fi

    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi
