package devlounge.spring.model.view;

import java.time.LocalDateTime;

public class FlightSpecialView {
    private long id;
    private String header;
    private String body;
    private String origin;
    private String originCode;
    private String destination;
    private String destinationCode;
    private Integer cost;
    private LocalDateTime expiryDate;
}
