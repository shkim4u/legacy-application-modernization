package gatling.test.example.simulation;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;
import io.gatling.javaapi.http.HttpProtocolBuilder;

import java.time.Duration;

import static gatling.test.example.simulation.PerfTestConfig.*;
import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.http;
import static io.gatling.javaapi.http.HttpDsl.status;

public class OpenLoadModelSimulation extends Simulation {

    HttpProtocolBuilder httpProtocol = (SHARE_CONNECTIONS ? http.baseUrl(BASE_URL) : http.baseUrl(BASE_URL).shareConnections())
            .header("Content-Type", "application/json")
            .header("Accept-Encoding", "gzip")
            .check(status().is(200));

    ScenarioBuilder scn = scenario("Root endpoint calls")
            .exec(http("root endpoint").post("/").body(StringBody("{}")));

    {
        /*
        1. nothingFor(duration): Pause for a given duration.
        2. atOnceUsers(nbUsers): Injects a given number of users at once.
        3. rampUsers(nbUsers).during(duration): Injects a given number of users distributed evenly on a time window of a given duration.
        4. constantUsersPerSec(rate).during(duration): Injects users at a constant rate, defined in users per second, during a given duration. Users will be injected at regular intervals.
        5. constantUsersPerSec(rate).during(duration).randomized: Injects users at a constant rate, defined in users per second, during a given duration. Users will be injected at randomized intervals.
        6. rampUsersPerSec(rate1).to(rate2).during(duration): Injects users from starting rate to target rate, defined in users per second, during a given duration. Users will be injected at regular intervals.
        7. rampUsersPerSec(rate1).to(rate2).during(duration).randomized: Injects users from starting rate to target rate, defined in users per second, during a given duration. Users will be injected at randomized intervals.
        8. stressPeakUsers(nbUsers).during(duration): Injects a given number of users following a smooth approximation of the heaviside step function stretched to a given duration.
         */
        setUp(scn.injectOpen(
                nothingFor(4),
                atOnceUsers(10), // 2
                rampUsers(10).during(5), // 3
                constantUsersPerSec(20).during(15), // 4
                constantUsersPerSec(20).during(15).randomized(), // 5
                rampUsersPerSec(10).to(20).during(10), // 6
                rampUsersPerSec(10).to(20).during(10).randomized(), // 7
                stressPeakUsers(1000).during(20) // 8
        )).protocols(httpProtocol)
                .assertions(global().responseTime().percentile3().lt(P95_RESPONSE_TIME_MS),
                        global().successfulRequests().percent().gt(95.0))
        ;
    }
}
