# Utilities for Docker images
Utilities for building docker images

## [Common Functions](common_functions.sh)

A collections of bash scripts to make easier the most common utilities in docker-image build time

### env_vars_in_file

Write your environment variables into a file.

For instance, suppose you have these vars and want to write them into a file "/conf.properties":

    SERVER_TIMEOUT=60
    SERVER_URL=https://mysite.com
    SERVER_BIND_IP=192.168.10.10

The [Dockerfile](examples/Dockerfile) would be like this:

```bash
FROM alpine

ENV SERVER_TIMEOUT=60 \
    SERVER_URL=https://mysite.com \
    SERVER_BIND_IP=192.168.10.10

RUN apk add --no-cache --virtual .build-deps \
      bash wget ca-certificates openssl

RUN ["wget", "https://raw.githubusercontent.com/engapa/utils-docker/master/common-functions.sh"]
RUN . common-functions.sh \
    && PREFIX=SERVER_ DEST_FILE='/conf.properties' DEBUG=true env_vars_in_file

#RUN apk del .build-deps
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

And finally, if you wanna change or add any more parameter then launch the container (or extended Dockerfile with 'ENV' entries) this way:

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





