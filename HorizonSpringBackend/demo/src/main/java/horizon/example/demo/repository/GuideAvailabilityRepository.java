package horizon.example.demo.repository;

import horizon.example.demo.entity.AvailabilityStatus;
import horizon.example.demo.entity.GuideAvailability;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface GuideAvailabilityRepository extends JpaRepository<GuideAvailability, Long>, JpaSpecificationExecutor<GuideAvailability> {
    List<GuideAvailability> findByTourGuideId(Long tourGuideId);
    List<GuideAvailability> findByStatus(AvailabilityStatus status);
}
