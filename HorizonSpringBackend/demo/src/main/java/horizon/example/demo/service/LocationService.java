package horizon.example.demo.service;

import horizon.example.demo.dto.request.UpdateLocationRequest;
import horizon.example.demo.dto.response.LocationResponse;

public interface LocationService {
    LocationResponse updateLocation(Long tourGuideId, UpdateLocationRequest request);

    LocationResponse getLocation(Long tourGuideId);
}
