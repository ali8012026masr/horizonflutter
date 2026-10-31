package horizon.example.demo.repository;

import horizon.example.demo.entity.ServiceRating;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceRatingRepository extends JpaRepository<ServiceRating, Long> {
    List<ServiceRating> findByProviderId(Long providerId);
}
