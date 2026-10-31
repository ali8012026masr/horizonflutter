package horizon.example.demo.service;

import horizon.example.demo.dto.response.BookingsSummaryResponse;
import horizon.example.demo.dto.response.CommissionSummaryResponse;
import horizon.example.demo.dto.response.RevenueSummaryResponse;
import java.time.LocalDateTime;

public interface AdminReportService {
    RevenueSummaryResponse revenueSummary(LocalDateTime dateFrom, LocalDateTime dateTo);
    BookingsSummaryResponse bookingsSummary(LocalDateTime dateFrom, LocalDateTime dateTo);
    CommissionSummaryResponse commissionSummary(LocalDateTime dateFrom, LocalDateTime dateTo);
}
