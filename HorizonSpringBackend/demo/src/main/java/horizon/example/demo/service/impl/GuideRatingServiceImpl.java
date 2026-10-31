package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateGuideRatingRequest;
import horizon.example.demo.dto.response.GuideRatingResponse;
import horizon.example.demo.entity.GuideBooking;
import horizon.example.demo.entity.GuideRating;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.GuideBookingRepository;
import horizon.example.demo.repository.GuideRatingRepository;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import horizon.example.demo.service.GuideRatingService;

@Service
@RequiredArgsConstructor
public class GuideRatingServiceImpl implements GuideRatingService {

    private final GuideRatingRepository guideRatingRepository;
    private final GuideBookingRepository guideBookingRepository;

    @Override
    @Transactional
    public GuideRatingResponse create(CreateGuideRatingRequest request) {
        GuideBooking guideBooking = guideBookingRepository.findById(request.getGuideBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Guide booking not found: " + request.getGuideBookingId()));

        GuideRating rating = GuideRating.builder()
                .guideBooking(guideBooking)
                .score(request.getScore())
                .comment(request.getComment())
                .ratedDate(LocalDateTime.now())
                .build();
        guideRatingRepository.save(rating);

        recalculateGuideRating(guideBooking.getTourGuide());

        return toResponse(rating);
    }

    @Override
    public List<GuideRatingResponse> listByGuide(Long guideId) {
        return guideRatingRepository.findByGuideBooking_TourGuideId(guideId).stream().map(this::toResponse).toList();
    }

    private void recalculateGuideRating(TourGuide guide) {
        List<GuideRating> ratings = guideRatingRepository.findByGuideBooking_TourGuideId(guide.getId());
        int count = ratings.size();
        double avg = ratings.stream().mapToInt(GuideRating::getScore).average().orElse(0);
        guide.setRatingCount(count);
        guide.setRatingAvg(avg);
    }

    private GuideRatingResponse toResponse(GuideRating rating) {
        return GuideRatingResponse.builder()
                .id(rating.getId())
                .guideBookingId(rating.getGuideBooking().getId())
                .score(rating.getScore())
                .comment(rating.getComment())
                .ratedDate(rating.getRatedDate())
                .build();
    }
}
