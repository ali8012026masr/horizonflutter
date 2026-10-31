package horizon.example.demo.repository;

import horizon.example.demo.entity.ServiceSlot;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ServiceSlotRepository extends JpaRepository<ServiceSlot, Long>, JpaSpecificationExecutor<ServiceSlot> {
    List<ServiceSlot> findByProviderId(Long providerId);
}
