FROM alpine:latest

LABEL maintainer="PRX <sysadmin@prx.org>"
LABEL org.prx.lambda="true"

WORKDIR /app

RUN apk add zip

RUN mkdir -p /.prxci
ADD index.js .
RUN zip -rq /.prxci/build.zip .
