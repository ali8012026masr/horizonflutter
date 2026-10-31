package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateBookingRequest;
import horizon.example.demo.dto.request.UpdateBookingStatusRequest;
import horizon.example.demo.dto.response.BookingResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.BookingStatus;
import horizon.example.demo.entity.PaymentStatus;
import horizon.example.demo.entity.ServiceSlot;
import horizon.example.demo.entity.SlotStatus;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.exception.InvalidStatusTransitionException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.exception.SlotUnavailableException;
import horizon.example.demo.repository.BookingRepository;
import horizon.example.demo.repository.ServiceSlotRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.service.BookingService;
import horizon.example.demo.service.CommissionService;
import horizon.example.demo.service.NotificationService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final ServiceSlotRepository serviceSlotRepository;
    private final TouristRepository touristRepository;
    private final CommissionService commissionService;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public BookingResponse create(CreateBookingRequest request) {
        Tourist tourist = touristRepository.findById(request.getTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getTouristId()));
        ServiceSlot slot = serviceSlotRepository.findById(request.getServiceSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("Service slot not found: " + request.getServiceSlotId()));

        if (slot.getStatus() != SlotStatus.OPEN || slot.getAvailableSeats() < 1) {
            throw new SlotUnavailableException("Service slot is not open or has no available seats: " + slot.getId());
        }

        slot.setAvailableSeats(slot.getAvailableSeats() - 1);
        if (slot.getAvailableSeats() == 0) {
            slot.setStatus(SlotStatus.FULL);
        }

        Booking booking = Booking.builder()
                .tourist(tourist)
                .serviceSlot(slot)
                .status(BookingStatus.PENDING)
                .totalAmount(slot.getPrice())
                .paymentStatus(PaymentStatus.UNPAID)
                .build();

        bookingRepository.save(booking);
        notificationService.create(
                slot.getProvider().getId(),
                "NEW_BOOKING",
                tourist.getFullName() + " booked your service: " + slot.getCategory());
        return toResponse(booking);
    }

    @Override
    @Transactional
    public BookingResponse updateStatus(Long id, UpdateBookingStatusRequest request) {
        Booking booking = findEntity(id);
        BookingStatus target = request.getStatus();

        switch (target) {
            case CANCELLED -> cancel(booking);
            case COMPLETED -> complete(booking);
            case CONFIRMED -> throw new InvalidStatusTransitionException(
                    "Booking can only move to CONFIRMED via payment success, not this endpoint");
            case PENDING -> throw new InvalidStatusTransitionException("Booking cannot be reverted to PENDING");
        }

        return toResponse(booking);
    }

    private void cancel(Booking booking) {
        if (booking.getStatus() != BookingStatus.PENDING && booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new InvalidStatusTransitionException(
                    "Only PENDING or CONFIRMED bookings can be cancelled, current status: " + booking.getStatus());
        }

        ServiceSlot slot = booking.getServiceSlot();
        slot.setAvailableSeats(slot.getAvailableSeats() + 1);
        if (slot.getStatus() == SlotStatus.FULL) {
            slot.setStatus(SlotStatus.OPEN);
        }

        if (booking.getPaymentStatus() == PaymentStatus.PAID) {
            booking.setPaymentStatus(PaymentStatus.REFUNDED);
        }
        booking.setStatus(BookingStatus.CANCELLED);
        notificationService.create(
                booking.getTourist().getId(),
                "BOOKING_CANCELLED",
                "Your booking for " + booking.getServiceSlot().getCategory() + " was cancelled.");
    }

    private void complete(Booking booking) {
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new InvalidStatusTransitionException(
                    "Only CONFIRMED bookings can be completed, current status: " + booking.getStatus());
        }
        if (booking.getServiceSlot().getEndDateTime().isAfter(java.time.LocalDateTime.now())) {
            throw new InvalidStatusTransitionException("Booking cannot be completed before the service slot ends");
        }
        booking.setStatus(BookingStatus.COMPLETED);
    }

    @Override
    @Transactional
    public Booking markConfirmedByPayment(Long bookingId) {
        Booking booking = findEntity(bookingId);
        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new InvalidStatusTransitionException(
                    "Only PENDING bookings can be confirmed by payment, current status: " + booking.getStatus());
        }
        booking.setStatus(BookingStatus.CONFIRMED);
        booking.setPaymentStatus(PaymentStatus.PAID);
        commissionService.calculateForBooking(booking);
        notificationService.create(
                booking.getTourist().getId(),
                "BOOKING_CONFIRMED",
                "Your booking for " + booking.getServiceSlot().getCategory() + " is confirmed.");
        return booking;
    }

    @Override
    public BookingResponse getById(Long id) {
        return toResponse(findEntity(id));
    }

    @Override
    public List<BookingResponse> listByTourist(Long touristId) {
        return bookingRepository.findByTouristId(touristId).stream().map(this::toResponse).toList();
    }

    @Override
    public List<BookingResponse> listByProvider(Long providerId) {
        return bookingRepository.findByServiceSlot_Provider_Id(providerId).stream().map(this::toResponse).toList();
    }

    private Booking findEntity(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + id));
    }

    private BookingResponse toResponse(Booking booking) {
        return BookingResponse.builder()
                .id(booking.getId())
                .touristId(booking.getTourist().getId())
                .serviceSlotId(booking.getServiceSlot().getId())
                .bookingDate(booking.getBookingDate())
                .status(booking.getStatus())
                .totalAmount(booking.getTotalAmount())
                .paymentStatus(booking.getPaymentStatus())
                .build();
    }
}
