package devlounge.spring;

import java.util.List;
import java.util.Random;
import java.util.concurrent.atomic.AtomicBoolean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import com.amazonaws.xray.AWSXRay;
import com.amazonaws.xray.entities.Segment;
import com.amazonaws.xray.entities.Subsegment;

import devlounge.spring.model.FlightSpecial;
import devlounge.spring.model.HotelSpecial;
import devlounge.spring.service.FlightSpecialService;
import devlounge.spring.service.HotelSpecialService;


@Controller
public class RESTController {

	private static final ResponseEntity<String> HEALTH_RESPONSE = ResponseEntity.ok().body("OK");
	private FlightSpecialService flightSpecialService;
	private HotelSpecialService  hotelSpecialService;

	private RestTemplate restTemplate = new RestTemplate();

	private AtomicBoolean isCpuLoadRunning = new AtomicBoolean(false);

	@Autowired(required=true)
	@Qualifier(value="flightSpecialService")
	public void setFlightSpecialService(FlightSpecialService svc){
		this.flightSpecialService = svc;
	}

	@Autowired(required=true)
	@Qualifier(value="hotelSpecialService")
	public void setHoteSpecialService(HotelSpecialService svc){
		this.hotelSpecialService = svc;
	}

	// ------------------------
	// PUBLIC METHODS
	// ------------------------
	@RequestMapping(path="/flightspecials", method = RequestMethod.GET)
	@ResponseBody
	@CrossOrigin("*")
	public List<FlightSpecial> flightspecials() {

		List<FlightSpecial> result = null;
		try {
			Subsegment subsegment = AWSXRay.beginSubsegment(this.getClass().getName() + "::flightspecials");
			result = this.flightSpecialService.findAll();
			subsegment.putMetadata("flightspecials", result);
		}
		catch (Exception ex) {

		}
		finally {
			AWSXRay.endSubsegment();
		}

		return result;
	}

//	@RequestMapping(path="/flightspecials-old/{id}", method = RequestMethod.GET)
//	@ResponseBody
//	@CrossOrigin("*")
//	public FlightSpecial flightspecials(@PathVariable("id") int id) {
//		/*
//		 * Handover the request to the newly decomposed FlightSpecials service with http://flightspecials-service.flightspecials/flightspecials/{id}.
//		 * Ideally this should be done inside outbound service to handover legacy and new service.
//		 */
//		FlightSpecial result = null;
//		try {
//			Subsegment subsegment = AWSXRay.beginSubsegment(this.getClass().getName() + "::flightspecials");
//			String url = "http://flightspecials-service.flightspecials/travelbuddy/flightspecials/" + id;
//			result = restTemplate.getForObject(url, FlightSpecial.class);
//			subsegment.putMetadata("flightspecial", result);
//		} catch (Exception ex) {
//			// Handle exception
//		} finally {
//			AWSXRay.endSubsegment();
//		}
//
//		return result;
//	}

	@RequestMapping(path="/flightspecials-old/{id}", method = RequestMethod.GET)
	@ResponseBody
	@CrossOrigin("*")
	public String flightspecials(@PathVariable("id") int id) {
		String result = null;
		try {
			Subsegment subsegment = AWSXRay.beginSubsegment(this.getClass().getName() + "::flightspecials");
			String url = "http://flightspecials-service.flightspecials/travelbuddy/flightspecials/" + id;
			result = restTemplate.getForObject(url, String.class);
			subsegment.putMetadata("flightspecial", result);
		} catch (Exception ex) {
			// Handle exception
			ex.printStackTrace();
		} finally {
			AWSXRay.endSubsegment();
		}

		return result;
	}

	@RequestMapping(path="/hotelspecials", method = RequestMethod.GET)
	@ResponseBody
	@CrossOrigin("*")
	public List<HotelSpecial> hotelspecials() {

		List<HotelSpecial> result = null;
		try {
			Subsegment subsegment = AWSXRay.beginSubsegment(this.getClass().getName() + "::hotelspecials");
			result = this.hotelSpecialService.findAll();
			subsegment.putMetadata("hotelspecials", result);
		}
		catch (Exception ex) {

		}
		finally {
			AWSXRay.endSubsegment();
		}
		return result;
	}

	@RequestMapping("/health")
	@GetMapping
	public ResponseEntity<String> health() {
		return HEALTH_RESPONSE;
	}

	@RequestMapping(path="/load-cpu", method = RequestMethod.GET)
	@ResponseBody
	public String loadCPU(@RequestParam(defaultValue = "60") int durationSeconds) {
		if (isCpuLoadRunning.compareAndSet(false, true)) {
			new Thread(() -> {
				long startTime = System.currentTimeMillis();
				long endTime = startTime + (durationSeconds * 1000);

				Random random = new Random();

				while (System.currentTimeMillis() < endTime && isCpuLoadRunning.get()) {
					// CPU를 사용하는 연산 수행
					for (int i = 0; i < 100000 && isCpuLoadRunning.get(); i++) {
						Math.sqrt(random.nextDouble());
					}
				}

				isCpuLoadRunning.set(false);
			}).start();

			return "CPU load test started. Duration: " + durationSeconds + " seconds";
		} else {
			return "CPU load test is already running";
		}
	}

	@RequestMapping(path="/stop-cpu", method = RequestMethod.GET)
	@ResponseBody
	public String stopCPU() {
		if (isCpuLoadRunning.compareAndSet(true, false)) {
			return "CPU load test stopped";
		} else {
			return "No CPU load test is currently running";
		}
	}
}

