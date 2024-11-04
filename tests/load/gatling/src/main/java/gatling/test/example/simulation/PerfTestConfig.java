package gatling.test.example.simulation;

import static gatling.test.example.simulation.SystemPropertiesUtil.*;

public final class PerfTestConfig {
    public static final String BASE_URL = getAsStringOrElse("baseUrl", "http://localhost:8080");
    public static final double REQUEST_PER_SECOND = getAsDoubleOrElse("requestPerSecond", 10f);
    public static final long DURATION_MIN = getAsIntOrElse("durationMin", 1);
    /** Closed load model test */
    public static final int INITIAL_CONCURRENT_USERS = getAsIntOrElse("initialConcurrentUsers", 100);
    public static final int INITIAL_CONCURRENT_USERS_DURATION = getAsIntOrElse("initialConcurrentUsersDuration", 30);
    public static final int MAX_CONCURRENT_USERS = getAsIntOrElse("maxConcurrentUsers", 1000);
    public static final int MAX_CONCURRENT_USERS_DURATION = getAsIntOrElse("maxConcurrentUsersDuration", 270);
    public static final int RAMPS_LASTING = getAsIntOrElse("rampsLasting", 10);
    public static final int LEVEL_LASTING = getAsIntOrElse("levelLasting", 30);
    public static final int INCREMENT_TIMES = getAsIntOrElse("incrementTimes", 10);
    public static final int INCREMENT_CONCURRENT_USERS_BY = getAsIntOrElse("incrementConcurrentUsersBy", 100);
    public static final int THINK_TIME_MILLIS_BETWEEN_CALLS = getAsIntOrElse("thinkTimeMillisBetweenCalls", 500);

    /** Success criteria */
    public static final int P95_RESPONSE_TIME_MS = getAsIntOrElse("p95ResponseTimeMs", 1000);
}
