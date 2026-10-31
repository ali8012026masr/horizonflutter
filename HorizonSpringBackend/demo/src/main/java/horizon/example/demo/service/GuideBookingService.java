package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateGuideBookingRequest;
import horizon.example.demo.dto.request.UpdateGuideBookingStatusRequest;
import horizon.example.demo.dto.response.GuideBookingResponse;
import java.util.List;

/**
 * When a GuideBooking referencing a GuideAvailability moves to ACCEPTED, that GuideAvailability
 * flips to BOOKED; if later DECLINED, it flips back to OPEN.
 */
public interface GuideBookingService {
    GuideBookingResponse create(CreateGuideBookingRequest request);
    GuideBookingResponse updateStatus(Long id, UpdateGuideBookingStatusRequest request);
    GuideBookingResponse markPaymentReceived(Long id);
    List<GuideBookingResponse> listByGuide(Long guideId);
    List<GuideBookingResponse> listByTourist(Long touristId);
}
