package horizon.example.demo.repository;

import horizon.example.demo.entity.Payment;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface PaymentRepository extends JpaRepository<Payment, Long>, JpaSpecificationExecutor<Payment> {
    List<Payment> findByBookingId(Long bookingId);
    List<Payment> findByGuideBookingId(Long guideBookingId);
    Optional<Payment> findFirstByBookingId(Long bookingId);
    Optional<Payment> findFirstByGuideBookingId(Long guideBookingId);
}
