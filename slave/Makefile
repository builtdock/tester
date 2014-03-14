build:
	docker build -t deis/buildbot-slave .

run:
	docker run --privileged deis/buildbot-slave
	exit 0

shell:
	docker run -t -i --privileged deis/buildbot-slave /bin/bash

clean:
	-docker rmi deis/buildbot-slave
