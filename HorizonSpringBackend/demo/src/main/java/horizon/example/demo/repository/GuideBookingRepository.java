package horizon.example.demo.repository;

import horizon.example.demo.entity.GuideBooking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GuideBookingRepository extends JpaRepository<GuideBooking, Long> {
    List<GuideBooking> findByTourGuideId(Long tourGuideId);
    List<GuideBooking> findByTouristId(Long touristId);
}
