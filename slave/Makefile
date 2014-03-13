build:
	docker build -t deis/buildbot-slave .

run:
	docker run deis/buildbot-slave
	exit 0

shell:
	docker run -t -i deis/buildbot-slave /bin/bash

clean:
	-docker rmi deis/buildbot-slave
