package com.amazon.proserve.application.flight.usecase;

import java.util.List;

import com.amazon.proserve.application.flight.view.FlightSpecialView;
import com.amazon.proserve.domain.flight.FlightSpecial;

public interface GetFlightSpecialUseCase {
    List<FlightSpecialView> getFlightSpecial();
    FlightSpecial getFlightSpecialById(int id);
    List<FlightSpecialView> getAllFlightSpecialsSortedByExpiryDate();
}
