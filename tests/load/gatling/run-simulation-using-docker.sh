#!/usr/bin/env bash
BASE_URL=${BASE_URL:-http://insurance-planning.mydemo.co.kr/travelbuddy/}
./mvnw clean package
docker build -t gatling-java-http:latest .
docker run -e "JAVA_OPTS=-DbaseUrl=${BASE_URL} -DinitialConcurrentUsers=10 -DinitialConcurrentUsersDuration=30 -DmaxConcurrentUsers=100 -DmaxConcurrentUsersDuration=300 -DrampsLasting=10 -DlevelLasting=30 -DincrementTimes=10 -DincrementConcurrentUsersBy=10 -DthinkTimeMillisBetweenCalls=500" -e SIMULATION_NAME=gatling.test.example.simulation.ClosedLoadModelSimulation gatling-java-http:latest
