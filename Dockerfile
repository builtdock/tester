FROM ubuntu:12.04
MAINTAINER Matt Boersma <matt@opdemand.com>

ENV DEBIAN_FRONTEND noninteractive

# install buildbot dependencies from the Ubuntu .deb repository
RUN apt-get update && \
    apt-get install -yq curl git-core libpq-dev libyaml-dev make python-dev \
        python-openssl

# install latest pip
RUN curl -s https://raw.github.com/pypa/pip/1.5.4/contrib/get-pip.py | python -

# install buildbot and buildbot-slave from the python package index
RUN pip install virtualenv==1.11.4 buildbot==0.8.8 buildbot-slave==0.8.8

# install docker-in-docker dependencies
RUN apt-get install -yqq aufs-tools iptables ca-certificates lxc
RUN echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-get update && apt-get install -yq lxc-docker
RUN pip install -q docker-py

# create a "buildmaster" user
RUN mkdir /app
RUN useradd buildmaster --create-home --home-dir /app/master --shell /bin/bash
RUN sudo -E -u buildmaster buildbot create-master --no-logrotate --relocatable /app/master
ADD . /app
RUN chown -R buildmaster: /app/master

# create a "buildslave" user
RUN useradd buildslave --create-home --home-dir /app/slave --shell /bin/bash --gid docker

# expose the public HTTP site and the twisted PB API interface port
EXPOSE 8010 9989
VOLUME /var/lib/docker
CMD ["/app/bin/start"]

