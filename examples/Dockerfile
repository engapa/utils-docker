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
