FROM public.ecr.aws/docker/library/eclipse-temurin:17.0.13_11-jre
MAINTAINER Sanghyoun Kim <sanghyou@amazon.com>

RUN apt update -y && apt install -y bash curl && apt clean all && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /app
RUN mkdir -m 0755 -p ${APP_HOME}/bin

COPY target/gatling-java-http.jar ${APP_HOME}/bin/

RUN groupadd -r gatling && useradd -r -ggatling gatling
RUN chown -R gatling:gatling ${APP_HOME}

USER gatling
WORKDIR ${APP_HOME}

COPY docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]

