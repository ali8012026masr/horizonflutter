package horizon.example.demo.repository;

import horizon.example.demo.entity.Commission;
import horizon.example.demo.entity.SettlementStatus;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommissionRepository extends JpaRepository<Commission, Long> {
    List<Commission> findBySettlementStatus(SettlementStatus settlementStatus);
    List<Commission> findByCalculatedDateBetween(LocalDateTime from, LocalDateTime to);
    Optional<Commission> findByBookingId(Long bookingId);
    Optional<Commission> findByGuideBookingId(Long guideBookingId);
    List<Commission> findByBooking_ServiceSlot_Provider_Id(Long providerId);
}
