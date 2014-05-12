build:
	docker build --tag=deis/tester .

run:
	docker run \
		--detach=true \
		--privileged=true \
		--publish=:8080:8080 \
		--tty \
		deis/tester

shell:
	docker run \
		--interactive \
		--privileged=true \
		--publish=:8080:8080 \
		--tty \
		deis/tester /bin/bash

clean:
	-docker rmi deis/tester

nuke_from_orbit:
	-docker kill `docker ps -q`
	-docker rm `docker ps -a -q`
	-docker rmi `docker images -q`

