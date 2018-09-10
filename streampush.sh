#!/usr/bin/env bash

# Check for Docker requirements
docker --version
docker-compose --version

if [ "$1" == "install" ]
then
    # Get the docker-compose.yml file (or generate it)
    # Make some env var config changes based upon some user input
    # Run docker-compose pull
elif [ "$1" == "start" ]
then
    # Run docker-compose up
fi
