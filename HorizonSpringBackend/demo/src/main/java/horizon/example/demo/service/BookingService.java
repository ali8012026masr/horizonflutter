package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateBookingRequest;
import horizon.example.demo.dto.request.UpdateBookingStatusRequest;
import horizon.example.demo.dto.response.BookingResponse;
import horizon.example.demo.entity.Booking;
import java.util.List;

/**
 * Booking status/paymentStatus transition contract:
 * - Created as PENDING / UNPAID; availableSeats decrements immediately (optimistic hold), not on payment.
 * - PENDING -> CONFIRMED only when the linked Payment reaches SUCCESS (see markConfirmedByPayment,
 *   called from PaymentService — never settable directly by any other controller endpoint).
 * - -> CANCELLED via PUT /api/bookings/{id}/status; cancelling a PENDING or CONFIRMED booking restores
 *   availableSeats and, if paymentStatus was PAID, sets it to REFUNDED (bookkeeping only, no real refund).
 * - -> COMPLETED only after serviceSlot.endDateTime has passed and status was CONFIRMED; admin- or
 *   scheduler-triggerable via the status endpoint for now, no automatic job in this phase.
 */
public interface BookingService {
    BookingResponse create(CreateBookingRequest request);
    BookingResponse updateStatus(Long id, UpdateBookingStatusRequest request);
    BookingResponse getById(Long id);
    List<BookingResponse> listByTourist(Long touristId);
    List<BookingResponse> listByProvider(Long providerId);

    /** Called by PaymentService when a Payment for this booking reaches SUCCESS. */
    Booking markConfirmedByPayment(Long bookingId);
}
