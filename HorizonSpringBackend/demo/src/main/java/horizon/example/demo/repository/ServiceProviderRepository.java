package horizon.example.demo.repository;

import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.VerificationStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceProviderRepository extends JpaRepository<ServiceProvider, Long> {
    List<ServiceProvider> findByVerificationStatus(VerificationStatus verificationStatus);
}
