package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateServiceRatingRequest;
import horizon.example.demo.dto.response.ServiceRatingResponse;
import java.util.List;

public interface ServiceRatingService {
    ServiceRatingResponse create(CreateServiceRatingRequest request);
    List<ServiceRatingResponse> listByProvider(Long providerId);
}
