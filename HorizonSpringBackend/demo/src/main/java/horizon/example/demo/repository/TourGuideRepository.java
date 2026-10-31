package horizon.example.demo.repository;

import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.VerificationStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TourGuideRepository extends JpaRepository<TourGuide, Long> {
    List<TourGuide> findByIsAvailable(boolean isAvailable);
    List<TourGuide> findByVerificationStatus(VerificationStatus verificationStatus);
}
