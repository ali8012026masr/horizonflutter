package horizon.example.demo.repository;

import horizon.example.demo.entity.GuideRating;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GuideRatingRepository extends JpaRepository<GuideRating, Long> {
    List<GuideRating> findByGuideBooking_TourGuideId(Long tourGuideId);
}
