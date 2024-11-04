#!/bin/bash
SIMULATION_NAME=${SIMULATION_NAME:-gatling.test.example.simulation.ExampleSimulation}
java -Djava.util.prefs.userRoot=/app/.java/.userPrefs ${JAVA_OPTS} -cp bin/gatling-java-http.jar io.gatling.app.Gatling -s ${SIMULATION_NAME} --results-folder results

# Java 프로그램의 종료 코드 확인
exit_code=$?

# 종료 코드가 2인 경우 0으로 설정
if [ $exit_code -eq 2 ]; then
  exit 0
else
  exit $exit_code
fi
