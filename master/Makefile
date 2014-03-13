build:
	docker build -t deis/buildbot .

run:
	docker run -p :8010 -p :9989 deis/buildbot
	exit 0

shell:
	docker run -t -i deis/buildbot /bin/bash

clean:
	-docker rmi deis/buildbot
