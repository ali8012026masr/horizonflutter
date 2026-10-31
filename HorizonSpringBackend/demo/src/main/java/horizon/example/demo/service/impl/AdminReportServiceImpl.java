package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.PaymentSearchRequest;
import horizon.example.demo.dto.response.BookingsSummaryResponse;
import horizon.example.demo.dto.response.CommissionSummaryResponse;
import horizon.example.demo.dto.response.RevenueSummaryResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.BookingStatus;
import horizon.example.demo.entity.Commission;
import horizon.example.demo.entity.Payment;
import horizon.example.demo.entity.PaymentTxStatus;
import horizon.example.demo.entity.SettlementStatus;
import horizon.example.demo.repository.BookingRepository;
import horizon.example.demo.repository.CommissionRepository;
import horizon.example.demo.repository.PaymentRepository;
import horizon.example.demo.repository.spec.PaymentSpecifications;
import horizon.example.demo.service.AdminReportService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminReportServiceImpl implements AdminReportService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final CommissionRepository commissionRepository;

    @Override
    public RevenueSummaryResponse revenueSummary(LocalDateTime dateFrom, LocalDateTime dateTo) {
        PaymentSearchRequest search = PaymentSearchRequest.builder()
                .dateFrom(dateFrom)
                .dateTo(dateTo)
                .status(PaymentTxStatus.SUCCESS)
                .build();
        List<Payment> payments = paymentRepository.findAll(PaymentSpecifications.fromSearch(search));

        BigDecimal totalRevenue = payments.stream()
                .map(Payment::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalCommission = commissionInRange(dateFrom, dateTo).stream()
                .map(Commission::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return RevenueSummaryResponse.builder()
                .totalRevenue(totalRevenue)
                .totalCommission(totalCommission)
                .paymentCount(payments.size())
                .build();
    }

    @Override
    public BookingsSummaryResponse bookingsSummary(LocalDateTime dateFrom, LocalDateTime dateTo) {
        List<Booking> bookings = bookingRepository.findAll().stream()
                .filter(b -> dateFrom == null || !b.getBookingDate().isBefore(dateFrom))
                .filter(b -> dateTo == null || !b.getBookingDate().isAfter(dateTo))
                .toList();

        long pending = bookings.stream().filter(b -> b.getStatus() == BookingStatus.PENDING).count();
        long confirmed = bookings.stream().filter(b -> b.getStatus() == BookingStatus.CONFIRMED).count();
        long cancelled = bookings.stream().filter(b -> b.getStatus() == BookingStatus.CANCELLED).count();
        long completed = bookings.stream().filter(b -> b.getStatus() == BookingStatus.COMPLETED).count();

        return BookingsSummaryResponse.builder()
                .totalBookings(bookings.size())
                .pendingCount(pending)
                .confirmedCount(confirmed)
                .cancelledCount(cancelled)
                .completedCount(completed)
                .build();
    }

    @Override
    public CommissionSummaryResponse commissionSummary(LocalDateTime dateFrom, LocalDateTime dateTo) {
        List<Commission> commissions = commissionInRange(dateFrom, dateTo);

        BigDecimal total = commissions.stream().map(Commission::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal pending = commissions.stream()
                .filter(c -> c.getSettlementStatus() == SettlementStatus.PENDING)
                .map(Commission::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal settled = commissions.stream()
                .filter(c -> c.getSettlementStatus() == SettlementStatus.SETTLED)
                .map(Commission::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return CommissionSummaryResponse.builder()
                .totalCommission(total)
                .pendingCommission(pending)
                .settledCommission(settled)
                .build();
    }

    private List<Commission> commissionInRange(LocalDateTime dateFrom, LocalDateTime dateTo) {
        if (dateFrom != null && dateTo != null) {
            return commissionRepository.findByCalculatedDateBetween(dateFrom, dateTo);
        }
        return commissionRepository.findAll();
    }
}
