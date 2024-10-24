package devlounge.spring.service;

import java.util.List;
import java.util.Random;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import devlounge.spring.dao.FlightSpecialDAO;
import devlounge.spring.model.FlightSpecial;

@Service
public class FlightSpecialServiceImpl implements FlightSpecialService {

    private FlightSpecialDAO flightspecialDAO;
    private Random random = new Random();
    private RestTemplate restTemplate = new RestTemplate();

    private FlightSpecialDAO getFlightspecialDAO() {
        return flightspecialDAO;
    }

    public void setFlightspecialDAO(FlightSpecialDAO flightspecialDAO) {
        this.flightspecialDAO = flightspecialDAO;
    }

    @Override
    @Transactional
    public List<FlightSpecial> findAll() {
        // 10% 확률로 딜레이 적용
        if (random.nextDouble() < 0.1) {
            simulateSlowExternalCall();
        }
        return this.getFlightspecialDAO().findAll();
    }

    private void simulateSlowExternalCall() {
        // 500ms ~ 1500ms 사이의 랜덤한 딜레이 시간 계산
        long delay = 500 + random.nextInt(1001);

        // 외부 API 호출을 시뮬레이션
        String url = "https://httpbin.org/delay/" + (delay / 1000.0);
        restTemplate.getForObject(url, String.class);

        System.out.println("Applied delay of approximately " + delay + "ms");
    }

    @Override
    @Transactional
    public FlightSpecial findById(int id) {
        return this.getFlightspecialDAO().findById(id);
    }
}
