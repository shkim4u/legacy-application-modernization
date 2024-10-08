# Spring Dockerization > https://github.com/spring-guides/top-spring-boot-docker
# Base Image > https://hub.docker.com/r/adoptopenjdk/openjdk11/tags?page=1&name=jre-11.0.14.1_1-alpine
ARG BASE_REGISTRY="public.ecr.aws/amazoncorretto"
ARG BASE_IMG_NAME="amazoncorretto"
ARG BASE_IMG_VERS="17.0.12"
FROM ${BASE_REGISTRY}/${BASE_IMG_NAME}:${BASE_IMG_VERS}

ARG APP_NAME="restdoc-openapi"
ARG APP_VERSION="0.0.1-SNAPSHOT"

COPY build/libs/${APP_NAME}-${APP_VERSION}.jar /source001/boot.jar
RUN chmod +x /source001/boot.jar
#COPY build/api-spec/openapi3.json /source001/openapi3.json

ENV LC_ALL=C.UTF-8
ENV PROFILE="default"
ENV JAVA_HEAP_XMS="512m"
ENV JAVA_HEAP_XMX="512m"
ENV AWS_XRAY_CONTEXT_MISSING="LOG_ERROR"

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
