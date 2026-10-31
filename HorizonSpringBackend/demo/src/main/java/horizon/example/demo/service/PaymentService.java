package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreatePaymentRequest;
import horizon.example.demo.dto.request.PaymentSearchRequest;
import horizon.example.demo.dto.request.UpdatePaymentStatusRequest;
import horizon.example.demo.dto.response.PaymentResponse;
import java.util.List;

/** On status -> SUCCESS, flips the linked Booking (via BookingService) or GuideBooking accordingly. */
public interface PaymentService {
    PaymentResponse create(CreatePaymentRequest request);
    PaymentResponse getById(Long id);
    List<PaymentResponse> listByBooking(Long bookingId);
    PaymentResponse updateStatus(Long id, UpdatePaymentStatusRequest request);
    List<PaymentResponse> search(PaymentSearchRequest request);
}
