package horizon.example.demo.repository;

import horizon.example.demo.entity.LastKnownLocation;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LastKnownLocationRepository extends JpaRepository<LastKnownLocation, Long> {
    Optional<LastKnownLocation> findByTourGuideId(Long tourGuideId);
}
