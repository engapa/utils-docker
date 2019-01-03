# Basic utilities within Docker images/containers
[![Build status](https://circleci.com/gh/engapa/utils-docker/tree/master.svg?style=svg "Build status")](https://circleci.com/gh/engapa/utils-docker/tree/master)
[![Docker Pulls](https://img.shields.io/docker/pulls/engapa/utils-docker.svg)](https://hub.docker.com/r/engapa/utils-docker/)
[![Docker Layering](https://images.microbadger.com/badges/image/engapa/utils-docker.svg)](https://microbadger.com/images/engapa/utils-docker)
[![Docker image version](https://images.microbadger.com/badges/version/engapa/utils-docker.svg)](https://microbadger.com/images/engapa/utils-docker)
![OSS](https://badges.frapsoft.com/os/v1/open-source.svg?v=103 "We love OpenSource")

Known utilities to use/build docker containers/images

## [Common Functions](https://raw.githubusercontent.com/engapa/utils-docker/master/common-functions.sh)

A collection of bash functions to make easier common tasks

### env_vars_in_file

Write your environment variables into a file.

For instance, suppose you have these vars and want to write them into a file "/conf.properties":

    SERVER_TIMEOUT=60
    SERVER_URL=https://mysite.com
    SERVER_BIND_IP=192.168.10.10

The [Dockerfile](examples/Dockerfile) would be like this:

```bash
...
ENV SERVER_TIMEOUT=60 \
    SERVER_URL=https://mysite.com \
    SERVER_BIND_IP=192.168.10.10
...
RUN ["wget", "https://raw.githubusercontent.com/engapa/utils-docker/master/common-functions.sh"]
RUN . common-functions.sh \
    && PREFIX=SERVER_ DEST_FILE='/conf.properties' DEBUG=true env_vars_in_file
...
```

When we're building the Docker image we find out these lines in the output :

```bash
$ docker build -t engapa/common_functions --rm .
...
Step 5/6 : RUN . common-functions.sh && PREFIX=SERVER_ DEST_FILE='/conf.properties' DEBUG=true env_vars_in_file
 ---> Running in 4420331fd948
Writing environment variables to file :

PREFIX           : SERVER_
DEST_FILE        : /conf.properties
EXCLUSIONS       :
CREATE_FILE      : true
OVERRIDE         : true
FROM_SEPARATOR   : _
TO_SEPARATOR     : .
LOWER            : true
.......................................

[  ADD   ] : SERVER_BIND_IP --> bind.ip=192.168.10.10
[  ADD   ] : SERVER_TIMEOUT --> timeout=60
[  ADD   ] : SERVER_URL --> url=https://mysite.com
...
Successfully built c3cee6c14084
```

So, the contents of file /conf.properties, in a new container created from this image, are the expected:

```bash
$ docker run c3cee6c14084 cat /conf.properties
bind.ip=192.168.10.10
timeout=60
url=https://mysite.com
```

And finally, if you want to change or add any more parameter then launch the container (or extended Dockerfile with 'ENV' entries) like this:

```bash
$ docker run -e "SERVER_BIND_IP=0.0.0.0" -e "SERVER_VERIFY_SKIP=True" c3cee6c14084 \
  /bin/bash -c ". common-functions.sh && PREFIX=SERVER_ DEST_FILE='/conf.properties' DEBUG=true env_vars_in_file && cat /conf.properties"

Writing environment variables to file :

PREFIX           : SERVER_
DEST_FILE        : /conf.properties
EXCLUSIONS       :
CREATE_FILE      : true
OVERRIDE         : true
FROM_SEPARATOR   : _
TO_SEPARATOR     : .
LOWER            : true
.......................................

[OVERRIDE] : SERVER_BIND_IP --> bind.ip=0.0.0.0
[  ADD   ] : SERVER_VERIFY_SKIP --> verify.skip=True
[OVERRIDE] : SERVER_TIMEOUT --> timeout=60
[OVERRIDE] : SERVER_URL --> url=https://mysite.com

bind.ip=0.0.0.0
timeout=60
url=https://mysite.com
verify.skip=True
```


> NOTE: Do not forget to remove test containers and image to avoid resource consumption on your host by typing :
`$ docker rm -f $(docker ps -q -f ancestor=c3cee6c14084)`
`$ docker rmi c3cee6c14084`

## [GitHub Release](https://raw.githubusercontent.com/engapa/utils-docker/master/github.sh)

If you wonder how to publish a release on github this utility is for you.

### Publish a release on GitHub

The `gh-release` function aims you to publish a release in GitHub.

## All-in-One container

If you prefer to use directly a docker container, for instance in your workflow pipelines we may have a step like this one:

```bash
$ docker run -it engapa/utils-docker:latest
... Outputs all available functions ...
$ docker run -it engapa/utils-docker:latest log Hello Enk
[INFO] [2019-01-03_08:29:46] -  Hello Enk
```

