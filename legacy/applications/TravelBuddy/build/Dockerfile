# 애플리케이션 빌드 스테이지
#FROM maven:3.3.9-jdk-8 AS build
FROM public.ecr.aws/docker/library/maven:3.9.4-amazoncorretto-11 AS build
WORKDIR /app

# 빌드 성능 개선
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn -f pom.xml clean package

# 컨테이너 이미지 빌드 스테이지
# 하지만 아래 소스 이미지가 최선일까요?
#FROM tomcat:9-jdk11
FROM public.ecr.aws/docker/library/tomcat:9.0-jre11

# Prometheus JMX Exporter 다운로드 및 설정
# See: https://mvnrepository.com/artifact/io.prometheus.jmx/jmx_prometheus_javaagent
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar /opt/jmx_exporter.jar

# JMX Exporter 설정 파일 추가
ADD jmx_exporter_config.yaml /opt/jmx_exporter_config.yaml

# Tomcat 설정을 위한 환경 변수 추가
ENV CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote \
                   -Dcom.sun.management.jmxremote.local.only=false \
                   -Dcom.sun.management.jmxremote.port=9000 \
                   -Dcom.sun.management.jmxremote.rmi.port=9000 \
                   -Dcom.sun.management.jmxremote.ssl=false \
                   -Dcom.sun.management.jmxremote.authenticate=false \
                   -javaagent:/opt/jmx_exporter.jar=9404:/opt/jmx_exporter_config.yaml"

COPY --from=build /app/target/\*.war /usr/local/tomcat/webapps/travelbuddy.war
# (Optional) Make the "/travelbuddy/" path to root "/" with root healthcheck.
#COPY --from=build /app/target/\*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080 9000 9404

CMD ["catalina.sh", "run"]
