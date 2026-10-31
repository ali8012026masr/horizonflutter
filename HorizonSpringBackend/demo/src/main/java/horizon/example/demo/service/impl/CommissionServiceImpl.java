package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CommissionSearchRequest;
import horizon.example.demo.dto.response.CommissionResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.Commission;
import horizon.example.demo.entity.GuideBooking;
import horizon.example.demo.entity.SettlementStatus;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.CommissionRepository;
import horizon.example.demo.service.CommissionService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CommissionServiceImpl implements CommissionService {

    private final CommissionRepository commissionRepository;

    @Override
    @Transactional
    public void calculateForBooking(Booking booking) {
        if (commissionRepository.findByBookingId(booking.getId()).isPresent()) {
            return;
        }

        BigDecimal percentage = booking.getServiceSlot().getProvider().getCommissionRate();
        if (percentage == null) {
            percentage = BigDecimal.ZERO;
        }
        BigDecimal amount = booking.getTotalAmount()
                .multiply(percentage)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);

        Commission commission = Commission.builder()
                .booking(booking)
                .percentage(percentage)
                .amount(amount)
                .calculatedDate(LocalDateTime.now())
                .settlementStatus(SettlementStatus.PENDING)
                .build();

        commissionRepository.save(commission);
    }

    @Override
    @Transactional
    public void calculateForGuideBooking(GuideBooking guideBooking) {
        if (commissionRepository.findByGuideBookingId(guideBooking.getId()).isPresent()) {
            return;
        }

        BigDecimal percentage = guideBooking.getTourGuide().getCommissionRate();
        if (percentage == null) {
            percentage = BigDecimal.ZERO;
        }
        BigDecimal amount = guideBooking.getAgreedPrice()
                .multiply(percentage)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);

        Commission commission = Commission.builder()
                .guideBooking(guideBooking)
                .percentage(percentage)
                .amount(amount)
                .calculatedDate(LocalDateTime.now())
                .settlementStatus(SettlementStatus.PENDING)
                .build();

        commissionRepository.save(commission);
    }

    @Override
    public List<CommissionResponse> search(CommissionSearchRequest request) {
        List<Commission> commissions;
        if (request.getSettlementStatus() != null) {
            commissions = commissionRepository.findBySettlementStatus(request.getSettlementStatus());
        } else if (request.getDateFrom() != null && request.getDateTo() != null) {
            commissions = commissionRepository.findByCalculatedDateBetween(request.getDateFrom(), request.getDateTo());
        } else {
            commissions = commissionRepository.findAll();
        }
        return commissions.stream().map(this::toResponse).toList();
    }

    @Override
    public List<CommissionResponse> listByProvider(Long providerId) {
        return commissionRepository.findByBooking_ServiceSlot_Provider_Id(providerId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public CommissionResponse settle(Long id) {
        Commission commission = commissionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Commission not found: " + id));
        commission.setSettlementStatus(SettlementStatus.SETTLED);
        return toResponse(commission);
    }

    private CommissionResponse toResponse(Commission commission) {
        Booking booking = commission.getBooking();
        GuideBooking guideBooking = commission.getGuideBooking();

        String providerName = booking != null
                ? booking.getServiceSlot().getProvider().getBusinessName()
                : guideBooking.getTourGuide().getFullName();
        String serviceCategory = booking != null
                ? booking.getServiceSlot().getCategory().name()
                : "GUIDE_TOUR";

        return CommissionResponse.builder()
                .id(commission.getId())
                .bookingId(booking != null ? booking.getId() : null)
                .providerName(providerName)
                .serviceCategory(serviceCategory)
                .percentage(commission.getPercentage())
                .amount(commission.getAmount())
                .calculatedDate(commission.getCalculatedDate())
                .settlementStatus(commission.getSettlementStatus())
                .build();
    }
}
