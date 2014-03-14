#!/bin/bash

function echo_color {
  echo -e "\033[1m$1\033[0m"
}

function random_password {
  echo `< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32`
}

# set up necessary environment variables
: ${BUILDBOT_HOST:=`ifconfig | grep -Eo -m 1 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`}
: ${BUILDSLAVE_ADMIN:=Your Name Here <admin@youraddress.invalid>}
: ${BUILDBOT_IRC_CHANNEL:=#deis}
: ${BUILDBOT_IRC_NICKNAME:=deis-bot}
: ${BUILDBOT_URL:=http://$BUILDBOT_HOST:8010/}
: ${BUILDBOT_MASTER:=$BUILDBOT_HOST:9989}
: ${REPO_PATH:=https://github.com/opdemand/deis.git}
BUILDSLAVE1_USER=ubuntu-1
BUILDSLAVE1_PASS=$(random_password)
BUILDSLAVE2_USER=ubuntu-2
BUILDSLAVE2_PASS=$(random_password)
BUILDSLAVE3_USER=debian-1
BUILDSLAVE3_PASS=$(random_password)
BUILDSLAVE4_USER=macosx-1
BUILDSLAVE4_PASS=$(random_password)
BUILDSLAVE5_USER=windows-1
BUILDSLAVE5_PASS=$(random_password)

# start the buildbot master
echo_color "Starting buildbot master..."
docker run -d \
    -e REPO_PATH=$REPO_PATH \
    -e BUILDBOT_IRC_CHANNEL=$BUILDBOT_IRC_CHANNEL \
    -e BUILDBOT_IRC_NICKNAME=$BUILDBOT_IRC_NICKNAME \
    -e BUILDBOT_URL=$BUILDBOT_URL \
    -e BUILDSLAVE1_USER=$BUILDSLAVE1_USER \
    -e BUILDSLAVE1_PASS=$BUILDSLAVE1_PASS \
    -e BUILDSLAVE2_USER=$BUILDSLAVE2_USER \
    -e BUILDSLAVE2_PASS=$BUILDSLAVE2_PASS \
    -e BUILDSLAVE3_USER=$BUILDSLAVE3_USER \
    -e BUILDSLAVE3_PASS=$BUILDSLAVE3_PASS \
    -e BUILDSLAVE4_USER=$BUILDSLAVE4_USER \
    -e BUILDSLAVE4_PASS=$BUILDSLAVE4_PASS \
    -e BUILDSLAVE5_USER=$BUILDSLAVE5_USER \
    -e BUILDSLAVE5_PASS=$BUILDSLAVE5_PASS \
    -p :8010:8010 \
    -p :9989:9989 \
    -t deis/buildbot:latest

# start two buildslaves
echo_color "Starting slave ubuntu-1..."
docker run -d \
  --privileged \
  -e BUILDBOT_MASTER=$BUILDBOT_MASTER \
  -e BUILDSLAVE_USER=$BUILDSLAVE1_USER \
  -e BUILDSLAVE_PASS=$BUILDSLAVE1_PASS \
  -e BUILDSLAVE_ADMIN="$BUILDSLAVE_ADMIN" \
  -t deis/buildbot-slave:latest
echo_color "Starting slave ubuntu-2..."
docker run -d \
  --privileged \
  -e BUILDBOT_MASTER=$BUILDBOT_MASTER \
  -e BUILDSLAVE_USER=$BUILDSLAVE2_USER \
  -e BUILDSLAVE_PASS=$BUILDSLAVE2_PASS \
  -e BUILDSLAVE_ADMIN="$BUILDSLAVE_ADMIN" \
  -t deis/buildbot-slave:latest
# echo_color "Starting slave debian-1..."
# docker run -d \
#   --privileged \
#   -e BUILDBOT_MASTER=$BUILDBOT_MASTER \
#   -e BUILDSLAVE_USER=$BUILDSLAVE3_USER \
#   -e BUILDSLAVE_PASS=$BUILDSLAVE3_PASS \
#   -e BUILDSLAVE_ADMIN="$BUILDSLAVE_ADMIN" \
#   -t deis/buildbot-slave-debian:latest

# for now, just echo the remaining generated passwords so we can connect
# the other buildslaves manually.
echo "$BUILDSLAVE3_USER uses password $BUILDSLAVE3_PASS"
echo "$BUILDSLAVE4_USER uses password $BUILDSLAVE4_PASS"
echo "$BUILDSLAVE5_USER uses password $BUILDSLAVE5_PASS"
