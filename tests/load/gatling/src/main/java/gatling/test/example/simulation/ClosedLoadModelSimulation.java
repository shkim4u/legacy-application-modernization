package gatling.test.example.simulation;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;
import io.gatling.javaapi.http.HttpProtocolBuilder;

import java.time.Duration;

import static gatling.test.example.simulation.PerfTestConfig.*;
import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.http;
import static io.gatling.javaapi.http.HttpDsl.status;

public class ClosedLoadModelSimulation extends Simulation {

    HttpProtocolBuilder httpProtocol = (SHARE_CONNECTIONS ? http.baseUrl(BASE_URL) : http.baseUrl(BASE_URL).shareConnections())
            .header("Content-Type", "application/json")
            .header("Accept-Encoding", "gzip")
            .check(status().is(200));

    ScenarioBuilder scn = scenario("Root endpoint calls")
            .exec(http("root endpoint").post("/").body(StringBody("{}")))
            .pause(Duration.ofMillis(THINK_TIME_MILLIS_BETWEEN_CALLS)); // Think time.

    {
        /*
        1. constantConcurrentUsers(nbUsers).during(duration): Inject so that number of concurrent users in the system is constant
        2. rampConcurrentUsers(fromNbUsers).to(toNbUsers).during(duration): Inject so that number of concurrent users in the system ramps linearly from a number to another
         */
//        setUp(scn.injectClosed(
//                constantConcurrentUsers(INITIAL_CONCURRENT_USERS).during(INITIAL_CONCURRENT_USERS_DURATION), // 1
//                rampConcurrentUsers(INITIAL_CONCURRENT_USERS).to(MAX_CONCURRENT_USERS).during(10) // 2
//        )).protocols(httpProtocol)
//                .assertions(global().responseTime().percentile3().lt(P95_RESPONSE_TIME_MS),
//                        global().successfulRequests().percent().gt(95.0))
//        ;
        setUp(scn.injectClosed(
                incrementConcurrentUsers(INCREMENT_CONCURRENT_USERS_BY)
                        .times(INCREMENT_TIMES)
                        .eachLevelLasting(LEVEL_LASTING)
                        .separatedByRampsLasting(RAMPS_LASTING)
                        .startingFrom(INITIAL_CONCURRENT_USERS) // Int
        )).protocols(httpProtocol)
                .assertions(global().responseTime().percentile3().lt(P95_RESPONSE_TIME_MS),
                        global().successfulRequests().percent().gt(95.0))
        ;

    }
}
