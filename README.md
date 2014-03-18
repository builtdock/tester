# Deis Tester

Docker image containing a buildbot master and slave, for continuous integration testing of
the [Deis](http://deis.io) open source PaaS.

This Docker image is based on the official [ubuntu:12.04](https://index.docker.io/_/ubuntu/) base image.

## Usage

These Makefile commands are the interface to deis/tester:
- `make build`
- `make run`
- `make test`
- `make shell`
- `make clean`

The following environment variables, if set, customize the behavior of the
`make run` and `make shell` commands:
- **BUILDBOT_HOST**
- **BUILDBOT_IRC_CHANNEL**
- **BUILDBOT_IRC_NICKNAME**
- **BUILDBOT_MAIL_FROM_ADDR**
- **BUILDBOT_MAIL_RECIPIENTS**
- **BUILDBOT_MAIL_SMTP_RELAY**
- **BUILDBOT_MAIL_SMTP_USER**
- **BUILDBOT_MAIL_SMTP_PASSWORD**
- **BUILDBOT_MASTER**
- **BUILDBOT_PROJECT_NAME**
- **BUILDBOT_PROJECT_URL**
- **BUILDBOT_URL**
- **BUILDSLAVE_ADMIN**
- **REPO_PATH**

## License

Copyright 2014 OpDemand LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
