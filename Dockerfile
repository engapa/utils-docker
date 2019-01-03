FROM alpine

RUN apk add --no-cache --virtual .build-deps \
      bash wget ca-certificates openssl jq curl

ADD ./*.sh ./

ENTRYPOINT ["./entrypoint.sh"]