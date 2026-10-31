package horizon.example.demo.service;

import horizon.example.demo.dto.request.CommissionSearchRequest;
import horizon.example.demo.dto.response.CommissionResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.GuideBooking;
import java.util.List;

public interface CommissionService {
    /** Auto-calculates and persists a Commission when a Booking is confirmed. */
    void calculateForBooking(Booking booking);

    /** Auto-calculates and persists a Commission when a GuideBooking's payment is received. */
    void calculateForGuideBooking(GuideBooking guideBooking);

    List<CommissionResponse> search(CommissionSearchRequest request);

    List<CommissionResponse> listByProvider(Long providerId);

    CommissionResponse settle(Long id);
}
