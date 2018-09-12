#!/usr/bin/env bash

# Check for Docker requirements
docker --version
docker-compose --version

if [ "$1" == "config" ]
then
    echo "Streampush configuration:\n\t1) App ports\n\t2) Nginx config\n\t3) Done"

    APP_PORT=8000
    RTMP_PORT=1935
    APP_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1)

    echo "App ports"
    echo -n "Use default ports: HTTP=8000, RTMP=1935? (Y/n): "
    read USE_DEFAULTS
    if [ "$USE_DEFAULTS" == "n" ]
    then
        echo -n "HTTP Port (Default=8000): "
        read APP_PORT

        if [ "$APP_PORT" == "" ]
        then
            APP_PORT=8000
        fi

        echo -n "RTMP Port (Default=1935): "
        read RTMP_PORT

        if [ "$APP_PORT" == "" ]
        then
            RTMP_PORT=1935
        fi
    fi

    echo "Nginx config"
    echo -n "Would you like to setup an nginx reverse proxy for streampush with SSL? This is recommended for publicly-accesible installs. (Y/n)"
    read REV_PRXY
    if [ "$REV_PRXY" != "n" ]
    then
        echo -n "Please enter the FQDN of your installation (ex: streampush.io): "
        read FQDN

        SP_NGINX=`cat <<EOL
nginx:
        image: jwilder/nginx-proxy
        volumes:
            - ./spdata/certs:/etc/nginx/certs:ro
            - /etc/nginx/vhost.d/
            - /usr/share/nginx/html
            - /var/run/docker.sock:/tmp/docker.sock:ro
        labels:
            - "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy"
        ports:
            - "80:80"
            - "443:443"
    ssl:
        image: jrcs/letsencrypt-nginx-proxy-companion
        volumes:
            - ./spdata/certs:/etc/nginx/certs:rw
            - /var/run/docker.sock:/var/run/docker.sock:ro
            - /etc/nginx/vhost.d/
            - /usr/share/nginx/html
        depends_on:
            - nginx
EOL
`

        SP_VHOST="- VIRTUAL_HOST=${FQDN}"
        SP_LEHOST="- LETSENCRYPT_HOST=${FQDN}"
        SP_LEEMAIL="- LETSENCRYPT_EMAIL=fakeemail@asdasdasdadsdasd.com"
    fi

    cat > docker-compose.yml <<EOL
version: '3'

services:
    ${SP_NGINX}
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
            $SP_VHOST
            $SP_LEHOST
            $SP_LEEMAIL
        depends_on:
            - ssl
    relay:
        image: streampush/relay
        volumes:
            - ./spdata:/opt/streampush/data
        ports:
            - "$RTMP_PORT:1935"
EOL

    echo "Streampush is configured. Run \`./streampush.sh start\` to start Streampush."
elif [ "$1" == "start" ]
then
    # Run docker-compose up
    docker-compose -p streampush up -d
elif [ "$1" == "stop" ]
then
    docker-compose -p streampush down
fi
