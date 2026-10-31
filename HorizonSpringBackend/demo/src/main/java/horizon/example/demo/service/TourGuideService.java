package horizon.example.demo.service;

import horizon.example.demo.dto.request.UpdateGuideRequest;
import horizon.example.demo.dto.response.GuideResponse;
import java.util.List;

public interface TourGuideService {
    GuideResponse getById(Long id);
    GuideResponse update(Long id, UpdateGuideRequest request);
    List<GuideResponse> listAvailable(boolean available);
    void delete(Long id);
}
