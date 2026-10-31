package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreateGuideRatingRequest;
import horizon.example.demo.dto.request.CreateServiceRatingRequest;
import horizon.example.demo.dto.response.GuideRatingResponse;
import horizon.example.demo.dto.response.ServiceRatingResponse;
import horizon.example.demo.service.GuideRatingService;
import horizon.example.demo.service.ServiceRatingService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
public class RatingController {

    private final GuideRatingService guideRatingService;
    private final ServiceRatingService serviceRatingService;

    @PostMapping("/guide")
    public ResponseEntity<GuideRatingResponse> createGuideRating(@Valid @RequestBody CreateGuideRatingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(guideRatingService.create(request));
    }

    @GetMapping("/guide/{guideId}")
    public List<GuideRatingResponse> listGuideRatings(@PathVariable Long guideId) {
        return guideRatingService.listByGuide(guideId);
    }

    @PostMapping("/service")
    public ResponseEntity<ServiceRatingResponse> createServiceRating(@Valid @RequestBody CreateServiceRatingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(serviceRatingService.create(request));
    }

    @GetMapping("/provider/{providerId}")
    public List<ServiceRatingResponse> listProviderRatings(@PathVariable Long providerId) {
        return serviceRatingService.listByProvider(providerId);
    }
}
