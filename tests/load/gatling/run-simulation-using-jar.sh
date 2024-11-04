#!/usr/bin/env bash
BASE_URL=${BASE_URL:-http://insurance-planning.mydemo.co.kr/travelbuddy/}
JAVA_OPTS="-DbaseUrl=${BASE_URL} -DinitialConcurrentUsers=10 -DinitialConcurrentUsersDuration=30 -DmaxConcurrentUsers=100 -DmaxConcurrentUsersDuration=300 -DrampsLasting=10 -DlevelLasting=30 -DincrementTimes=10 -DincrementConcurrentUsersBy=10 -DthinkTimeMillisBetweenCalls=500"
SIMULATION_NAME=gatling.test.example.simulation.ClosedLoadModelSimulation
./mvnw clean package
java ${JAVA_OPTS} -cp target/gatling-java-http.jar io.gatling.app.Gatling --simulation "${SIMULATION_NAME}" --results-folder results
