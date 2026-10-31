package horizon.example.demo.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import horizon.example.demo.dto.request.CommissionSearchRequest;
import horizon.example.demo.dto.request.PaymentSearchRequest;
import horizon.example.demo.dto.request.UpdateUserStatusRequest;
import horizon.example.demo.dto.request.VerifyGuideRequest;
import horizon.example.demo.dto.request.VerifyProviderRequest;
import horizon.example.demo.dto.response.AdminUserResponse;
import horizon.example.demo.dto.response.BookingsSummaryResponse;
import horizon.example.demo.dto.response.CommissionResponse;
import horizon.example.demo.dto.response.CommissionSummaryResponse;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.dto.response.PaymentResponse;
import horizon.example.demo.dto.response.ProviderResponse;
import horizon.example.demo.dto.response.RevenueSummaryResponse;
import horizon.example.demo.entity.PaymentMethod;
import horizon.example.demo.entity.PaymentTxStatus;
import horizon.example.demo.entity.SettlementStatus;
import horizon.example.demo.service.AdminReportService;
import horizon.example.demo.service.AdminService;
import horizon.example.demo.service.CommissionService;
import horizon.example.demo.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final PaymentService paymentService;
    private final CommissionService commissionService;
    private final AdminReportService adminReportService;

    @GetMapping("/pending-registrations")
    public PendingRegistrationsResponse pendingRegistrations() {
        return new PendingRegistrationsResponse(
                adminService.listPendingProviders(),
                adminService.listPendingGuides());
    }

    @PutMapping("/providers/{id}/verify")
    public ProviderResponse verifyProvider(@PathVariable Long id, @Valid @RequestBody VerifyProviderRequest request) {
        return adminService.verifyProvider(id, request);
    }

    @PutMapping("/guides/{id}/verify")
    public GuideResponse verifyGuide(@PathVariable Long id, @Valid @RequestBody VerifyGuideRequest request) {
        return adminService.verifyGuide(id, request);
    }

    @GetMapping("/users")
    public List<AdminUserResponse> listUsers(@RequestParam(required = false) String role,
                                              @RequestParam(required = false) String status) {
        return adminService.listUsers(role, status);
    }

    @PutMapping("/users/{id}/status")
    public AdminUserResponse updateUserStatus(@PathVariable Long id, @Valid @RequestBody UpdateUserStatusRequest request) {
        return adminService.updateUserStatus(id, request);
    }

    @GetMapping("/payments")
    public List<PaymentResponse> listPayments(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo,
            @RequestParam(required = false) PaymentTxStatus status,
            @RequestParam(required = false) PaymentMethod method) {
        PaymentSearchRequest request = PaymentSearchRequest.builder()
                .dateFrom(dateFrom)
                .dateTo(dateTo)
                .status(status)
                .method(method)
                .build();
        return paymentService.search(request);
    }

    @GetMapping("/commissions")
    public List<CommissionResponse> listCommissions(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo,
            @RequestParam(required = false) SettlementStatus settlementStatus) {
        CommissionSearchRequest request = CommissionSearchRequest.builder()
                .dateFrom(dateFrom)
                .dateTo(dateTo)
                .settlementStatus(settlementStatus)
                .build();
        return commissionService.search(request);
    }

    @PutMapping("/commissions/{id}/settle")
    public CommissionResponse settleCommission(@PathVariable Long id) {
        return commissionService.settle(id);
    }

    @GetMapping("/reports/revenue-summary")
    public RevenueSummaryResponse revenueSummary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo) {
        return adminReportService.revenueSummary(dateFrom, dateTo);
    }

    @GetMapping("/reports/bookings-summary")
    public BookingsSummaryResponse bookingsSummary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo) {
        return adminReportService.bookingsSummary(dateFrom, dateTo);
    }

    @GetMapping("/reports/commission-summary")
    public CommissionSummaryResponse commissionSummary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo) {
        return adminReportService.commissionSummary(dateFrom, dateTo);
    }

    public record PendingRegistrationsResponse(List<ProviderResponse> providers, List<GuideResponse> guides) {
    }
}
