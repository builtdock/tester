FROM ubuntu:12.04
MAINTAINER Matt Boersma <matt@opdemand.com>

ENV DEBIAN_FRONTEND noninteractive

# install buildbot-slave dependencies from the Ubuntu .deb repository
RUN apt-get update && \
    apt-get install -yq curl git-core libyaml-dev libpq-dev make python-dev python-pip python-virtualenv

# install buildbot-slave from the python package index
RUN pip install -q buildbot-slave==0.8.8

# install docker-in-docker dependencies
RUN apt-get install -yqq aufs-tools iptables ca-certificates lxc
RUN echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-get update && apt-get install -yq lxc-docker
RUN pip install -q docker-py

# run as non-root user "buildslave"
RUN useradd buildslave --create-home --home-dir /app --shell /bin/bash --gid docker
RUN echo "buildslave ALL=NOPASSWD:/app/bin/wrapdocker" > /etc/sudoers.d/buildslave && \
    chmod 0440 /etc/sudoers.d/buildslave && \
    chmod u+s /usr/bin/sudo
USER buildslave
ENV HOME /app
WORKDIR /app
ADD . /app

VOLUME /var/lib/docker
CMD ["/app/bin/run"]
