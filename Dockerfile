FROM alpine:latest

MAINTAINER PRX <sysadmin@prx.org>
LABEL org.prx.lambda="true"

WORKDIR /app

RUN apk add zip

RUN mkdir -p /.prxci
ADD lambda_function.py .
RUN zip -rq /.prxci/build.zip .
