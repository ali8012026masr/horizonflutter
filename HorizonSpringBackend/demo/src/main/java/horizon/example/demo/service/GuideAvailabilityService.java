package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateGuideAvailabilityRequest;
import horizon.example.demo.dto.request.GuideAvailabilitySearchRequest;
import horizon.example.demo.dto.request.UpdateGuideAvailabilityRequest;
import horizon.example.demo.dto.response.GuideAvailabilityResponse;
import java.util.List;

public interface GuideAvailabilityService {
    GuideAvailabilityResponse create(CreateGuideAvailabilityRequest request);
    GuideAvailabilityResponse update(Long id, UpdateGuideAvailabilityRequest request);
    void cancel(Long id);
    List<GuideAvailabilityResponse> search(GuideAvailabilitySearchRequest request);
    List<GuideAvailabilityResponse> listByGuide(Long guideId);
}
