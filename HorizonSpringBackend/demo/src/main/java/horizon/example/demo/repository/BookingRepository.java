package horizon.example.demo.repository;

import horizon.example.demo.entity.Booking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByTouristId(Long touristId);
    List<Booking> findByServiceSlot_Provider_Id(Long providerId);
}
