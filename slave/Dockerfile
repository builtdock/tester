FROM ubuntu:12.04
MAINTAINER Matt Boersma <matt@opdemand.com>

ENV DEBIAN_FRONTEND noninteractive

# install buildbot-slave dependencies from the Ubuntu .deb repository
RUN apt-get update && \
    apt-get install -yq curl git-core libyaml-dev libpq-dev make python-dev python-pip python-virtualenv

# install buildbot-slave from the python package index
RUN pip install buildbot-slave==0.8.8

# run as non-root user "buildslave"
RUN useradd buildslave --create-home --home-dir /app --shell /bin/bash
USER buildslave
ENV HOME /app
WORKDIR /app
ADD . /app

CMD ["/app/bin/run"]
