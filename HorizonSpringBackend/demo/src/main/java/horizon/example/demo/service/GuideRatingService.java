package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateGuideRatingRequest;
import horizon.example.demo.dto.response.GuideRatingResponse;
import java.util.List;

public interface GuideRatingService {
    GuideRatingResponse create(CreateGuideRatingRequest request);
    List<GuideRatingResponse> listByGuide(Long guideId);
}
