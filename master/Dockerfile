FROM ubuntu:12.04
MAINTAINER Matt Boersma <matt@opdemand.com>

ENV DEBIAN_FRONTEND noninteractive

# install buildbot dependencies from the Ubuntu .deb repository
RUN apt-get update && \
    apt-get install -yq python-dev python-pip python-openssl

# install buildbot from the python package index
RUN pip install buildbot==0.8.8

# run as non-root user "buildbot"
RUN useradd buildbot --create-home --home-dir /app --shell /bin/bash
USER buildbot
ENV HOME /app
WORKDIR /app
RUN buildbot create-master --no-logrotate --relocatable .
ADD . /app
CMD ["/app/bin/run"]

# expose the public HTTP site and the twisted PB API interface port
EXPOSE 8010 9989
