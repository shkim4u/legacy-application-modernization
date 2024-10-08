#!/bin/sh

### app 설정 ###
JAVA_OPTS="${JAVA_OPTS} -Xms${JAVA_HEAP_XMS} -Xmx${JAVA_HEAP_XMX}"
JAVA_OPTS="${JAVA_OPTS} -XX:MaxMetaspaceSize=256m"
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"
JAVA_OPTS="${JAVA_OPTS} -Dspring.backgroundpreinitializer.ignore=true"
JAVA_OPTS="${JAVA_OPTS} -Xlog:gc*=info:file=/var/log/gc.log:time,level,tags"

### app 실행 ###
#exec java -cp /source001:${CLASSPATH} ${JAVA_OPTS} -Dspring.profiles.active=${PROFILE} -jar /source001/boot.jar
exec java ${JAVA_OPTS} -Dspring.profiles.active=${PROFILE} -jar /source001/boot.jar
