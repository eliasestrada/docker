#!/usr/bin/env bash

# Check for Docker requirements
docker --version
docker-compose --version

if [ "$1" == "config" ]
then
    # Get the docker-compose.yml file (or generate it)
    # Make some env var config changes based upon some user input
    # Run docker-compose pull
    echo "Streampush Docker configuration"

    APP_PORT=8000
    RTMP_PORT=1935
    APP_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1)

    echo -n "Use default ports: HTTP=8000, RTMP=1935? (Y/n): "
    read USE_DEFAULTS
    if [ "$USE_DEFAULTS" == "n" ]
    then
        echo -n "HTTP Port (Default: 8000): "
        read APP_PORT

        if [ "$APP_PORT" == "" ]
        then
            APP_PORT=8000
        fi

        echo -n "RTMP Port (Default: 1935): "
        read RTMP_PORT

        if [ "$APP_PORT" == "" ]
        then
            RTMP_PORT=1935
        fi
    fi

    cat > docker-compose.yml <<EOL
version: '3'

services:
    db:
        image: redis
    app:
        image: streampush/streampush
        volumes:
            - ./spdata:/opt/streampush/data
        depends_on:
            - relay
            - db
        ports:
            - "$APP_PORT:8000"
        environment:
            - DJANGO_SECRET=$APP_SECRET
    relay:
        image: streampush/relay
        volumes:
            - ./spdata:/opt/streampush/data
        ports:
            - "$RTMP_PORT:1935"
EOL

    echo "Streampush is configured. Run \`streampush.sh start\` to start Streampush."
elif [ "$1" == "start" ]
then
    # Run docker-compose up
    docker-compose -p streampush up -d
elif [ "$1" == "stop" ]
then
    docker-compose -p streampush down
fi
