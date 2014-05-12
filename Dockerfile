FROM ubuntu:12.04
MAINTAINER Matt Boersma <matt@opdemand.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get install -yq ca-certificates curl git-core lxc sudo

# add docker apt-get repository
RUN echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

# add jenkins apt-get repository
RUN curl http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list

# install docker and jenkins
RUN apt-get update && \
	apt-get install -yq jenkins lxc-docker

# configure jenkins user
RUN sudo -Hu jenkins git config --global user.name Jenkins
RUN sudo -Hu jenkins git config --global user.email jenkins@deis.io

ADD bin /app/bin/
ADD plugins /var/lib/jenkins/.jenkins/plugins/
EXPOSE 8080
VOLUME ["/var/lib/jenkins"]
WORKDIR /app
CMD ["/app/bin/start"]
