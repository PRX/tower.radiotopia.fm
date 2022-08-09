FROM alpine:latest

LABEL maintainer="PRX <sysadmin@prx.org>"
LABEL org.prx.spire.publish.s3="LAMBDA_ZIP"

WORKDIR /app

RUN apk add zip

RUN mkdir --parents /.prxci

ADD index.js .

# This zip file is what will be deployed to the Lambda function.
# Add any necessary files to it.
RUN zip --quiet --recurse-paths /.prxci/build.zip .
