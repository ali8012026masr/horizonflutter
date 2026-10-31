package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreatePaymentRequest;
import horizon.example.demo.dto.request.PaymentSearchRequest;
import horizon.example.demo.dto.request.UpdatePaymentStatusRequest;
import horizon.example.demo.dto.response.PaymentResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.GuideBooking;
import horizon.example.demo.entity.Payment;
import horizon.example.demo.entity.PaymentTxStatus;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.BookingRepository;
import horizon.example.demo.repository.GuideBookingRepository;
import horizon.example.demo.repository.PaymentRepository;
import horizon.example.demo.repository.spec.PaymentSpecifications;
import horizon.example.demo.service.BookingService;
import horizon.example.demo.service.PaymentService;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final GuideBookingRepository guideBookingRepository;
    private final BookingService bookingService;

    @Override
    @Transactional
    public PaymentResponse create(CreatePaymentRequest request) {
        boolean hasBooking = request.getBookingId() != null;
        boolean hasGuideBooking = request.getGuideBookingId() != null;
        if (hasBooking == hasGuideBooking) {
            throw new InvalidRequestException("Exactly one of bookingId or guideBookingId must be set");
        }

        Booking booking = null;
        GuideBooking guideBooking = null;

        if (hasBooking) {
            booking = bookingRepository.findById(request.getBookingId())
                    .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + request.getBookingId()));
        } else {
            guideBooking = guideBookingRepository.findById(request.getGuideBookingId())
                    .orElseThrow(() -> new ResourceNotFoundException("Guide booking not found: " + request.getGuideBookingId()));
        }

        Payment payment = Payment.builder()
                .booking(booking)
                .guideBooking(guideBooking)
                .amount(request.getAmount())
                .method(request.getMethod())
                .status(PaymentTxStatus.PENDING)
                .transactionDate(LocalDateTime.now())
                .build();

        paymentRepository.save(payment);
        return toResponse(payment);
    }

    @Override
    public PaymentResponse getById(Long id) {
        return toResponse(findEntity(id));
    }

    @Override
    public List<PaymentResponse> listByBooking(Long bookingId) {
        return paymentRepository.findByBookingId(bookingId).stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public PaymentResponse updateStatus(Long id, UpdatePaymentStatusRequest request) {
        Payment payment = findEntity(id);
        payment.setStatus(request.getStatus());

        if (request.getStatus() == PaymentTxStatus.SUCCESS) {
            if (payment.getBooking() != null) {
                bookingService.markConfirmedByPayment(payment.getBooking().getId());
            } else if (payment.getGuideBooking() != null) {
                payment.getGuideBooking().setPaymentReceived(true);
            }
        }

        return toResponse(payment);
    }

    @Override
    public List<PaymentResponse> search(PaymentSearchRequest request) {
        return paymentRepository.findAll(PaymentSpecifications.fromSearch(request)).stream()
                .map(this::toResponse)
                .toList();
    }

    private Payment findEntity(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found: " + id));
    }

    private PaymentResponse toResponse(Payment payment) {
        return PaymentResponse.builder()
                .id(payment.getId())
                .bookingId(payment.getBooking() != null ? payment.getBooking().getId() : null)
                .guideBookingId(payment.getGuideBooking() != null ? payment.getGuideBooking().getId() : null)
                .amount(payment.getAmount())
                .method(payment.getMethod())
                .status(payment.getStatus())
                .transactionDate(payment.getTransactionDate())
                .build();
    }
}
