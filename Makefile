build:
	docker build --tag=deis/tester .

run:
	docker run \
	    -e BUILDBOT_HOST="$$BUILDBOT_HOST" \
	    -e BUILDBOT_IRC_CHANNEL="$$BUILDBOT_IRC_CHANNEL" \
	    -e BUILDBOT_IRC_NICKNAME="$$BUILDBOT_IRC_NICKNAME" \
	    -e BUILDBOT_MAIL_FROM_ADDR="$$BUILDBOT_MAIL_FROM_ADDR" \
	    -e BUILDBOT_MAIL_RECIPIENTS="$$BUILDBOT_MAIL_RECIPIENTS" \
	    -e BUILDBOT_MAIL_SMTP_RELAY="$$BUILDBOT_MAIL_SMTP_RELAY" \
	    -e BUILDBOT_MAIL_SMTP_USER="$$BUILDBOT_MAIL_SMTP_USER" \
	    -e BUILDBOT_MAIL_SMTP_PASSWORD="$$BUILDBOT_MAIL_SMTP_PASSWORD" \
	    -e BUILDBOT_MASTER="$$BUILDBOT_MASTER" \
	    -e BUILDBOT_PROJECT_NAME="$$BUILDBOT_PROJECT_NAME" \
	    -e BUILDBOT_PROJECT_URL="$$BUILDBOT_PROJECT_URL" \
	    -e BUILDBOT_URL="$$BUILDBOT_URL" \
	    -e BUILDSLAVE_ADMIN="$$BUILDSLAVE_ADMIN" \
	    -e REPO_PATH="$$REPO_PATH" \
	    --privileged=true \
	    --publish=:8010:8010 \
	    --publish=:9989:9989 \
	    --tty \
	    deis/tester

flake8:
	flake8 \
		--exclude='venv/,virtualenv/' \
		--filename='*.py,master.cfg' \
		--max-complexity=12 \
		--max-line-length=99 \
		.

test: flake8

shell:
	docker run \
	    -e BUILDBOT_HOST="$$BUILDBOT_HOST" \
	    -e BUILDBOT_IRC_CHANNEL="$$BUILDBOT_IRC_CHANNEL" \
	    -e BUILDBOT_IRC_NICKNAME="$$BUILDBOT_IRC_NICKNAME" \
	    -e BUILDBOT_MAIL_FROM_ADDR="$$BUILDBOT_MAIL_FROM_ADDR" \
	    -e BUILDBOT_MAIL_RECIPIENTS="$$BUILDBOT_MAIL_RECIPIENTS" \
	    -e BUILDBOT_MAIL_SMTP_RELAY="$$BUILDBOT_MAIL_SMTP_RELAY" \
	    -e BUILDBOT_MAIL_SMTP_USER="$$BUILDBOT_MAIL_SMTP_USER" \
	    -e BUILDBOT_MAIL_SMTP_PASSWORD="$$BUILDBOT_MAIL_SMTP_PASSWORD" \
	    -e BUILDBOT_MASTER="$$BUILDBOT_MASTER" \
	    -e BUILDBOT_PROJECT_NAME="$$BUILDBOT_PROJECT_NAME" \
	    -e BUILDBOT_PROJECT_URL="$$BUILDBOT_PROJECT_URL" \
	    -e BUILDBOT_URL="$$BUILDBOT_URL" \
	    -e BUILDSLAVE_ADMIN="$$BUILDSLAVE_ADMIN" \
	    -e REPO_PATH="$$REPO_PATH" \
	    --interactive \
	    --privileged=true \
	    --publish=:8010:8010 \
	    --publish=:9989:9989 \
	    --tty \
	    deis/tester /bin/bash

clean:
	-docker rmi deis/tester

nuke_from_orbit:
	-docker kill `docker ps -q`
	-docker rm `docker ps -a -q`
	-docker rmi `docker images -q`
