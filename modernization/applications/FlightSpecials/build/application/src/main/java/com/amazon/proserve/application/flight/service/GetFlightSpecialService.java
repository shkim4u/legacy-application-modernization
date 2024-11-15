package com.amazon.proserve.application.flight.service;

import com.amazon.proserve.application.flight.usecase.GetFlightSpecialUseCase;
import com.amazon.proserve.application.flight.view.FlightSpecialView;
import com.amazon.proserve.domain.flight.FlightSpecial;
import com.amazon.proserve.domain.flight.repository.FlightSpecialRepository;

import com.amazon.proserve.domain.flight.vo.Id;
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GetFlightSpecialService implements GetFlightSpecialUseCase {
    private final FlightSpecialRepository repository;

    @Override
    public List<FlightSpecialView> getFlightSpecial() {
        List<FlightSpecial> list = repository.findAll();
        return list.stream().map(x -> FlightSpecialView.of(x)).collect(Collectors.toList());
    }

    @Override
    public FlightSpecialView getFlightSpecialById(int id) {
        FlightSpecial flightSpecial = repository.findById(Id.of((long)id));
        return FlightSpecialView.of(flightSpecial);
    }

    @Override
    public List<FlightSpecialView> getAllFlightSpecialsSortedByExpiryDate() {
        List<FlightSpecial> list = repository.findAllByOrderByExpiryDateAsc();
        return list.stream().map(x -> FlightSpecialView.of(x)).collect(Collectors.toList());
    }
}
