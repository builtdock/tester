#!/bin/bash

function echo_color {
  echo -e "\033[1m$1\033[0m"
}

# set up necessary environment variables
: ${BUILDBOT_HOST:=`ifconfig | grep -Eo -m 1 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`}
: ${BUILDSLAVE_ADMIN:=Your Name Here <admin@youraddress.invalid>}
: ${BUILDBOT_IRC_CHANNEL:=#deis}
: ${BUILDBOT_URL:=http://$BUILDBOT_HOST:8010/}
: ${BUILDBOT_MASTER:=$BUILDBOT_HOST:9989}
: ${REPO_PATH:=https://github.com/opdemand/deis.git}
BUILDSLAVE1_USER=buildslave1
BUILDSLAVE1_PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32`
BUILDSLAVE2_USER=buildslave2
BUILDSLAVE2_PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32`

# start the buildbot master
echo_color "Starting buildbot master..."
# docker cp fca032bcd646:/app /
docker run -d \
    -e REPO_PATH=$REPO_PATH \
    -e BUILDBOT_IRC_CHANNEL=$BUILDBOT_IRC_CHANNEL \
    -e BUILDBOT_URL=$BUILDBOT_URL \
    -e BUILDSLAVE1_USER=$BUILDSLAVE1_USER \
    -e BUILDSLAVE1_PASS=$BUILDSLAVE1_PASS \
    -e BUILDSLAVE2_USER=$BUILDSLAVE2_USER \
    -e BUILDSLAVE2_PASS=$BUILDSLAVE2_PASS \
    -p :8010:8010 \
    -p :9989:9989 \
    -t deis/buildbot:latest

# start two buildslaves
echo_color "Starting buildslave1..."
docker run -d \
  --privileged \
  -e BUILDBOT_MASTER=$BUILDBOT_MASTER \
  -e BUILDSLAVE_USER=$BUILDSLAVE1_USER \
  -e BUILDSLAVE_PASS=$BUILDSLAVE1_PASS \
  -e BUILDSLAVE_ADMIN="$BUILDSLAVE_ADMIN" \
  -t deis/buildbot-slave:latest
echo_color "Starting buildslave2..."
docker run -d \
  --privileged \
  -e BUILDBOT_MASTER=$BUILDBOT_MASTER \
  -e BUILDSLAVE_USER=$BUILDSLAVE2_USER \
  -e BUILDSLAVE_PASS=$BUILDSLAVE2_PASS \
  -e BUILDSLAVE_ADMIN="$BUILDSLAVE_ADMIN" \
  -t deis/buildbot-slave:latest
