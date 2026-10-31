package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateGuideBookingRequest;
import horizon.example.demo.dto.request.UpdateGuideBookingStatusRequest;
import horizon.example.demo.dto.response.GuideBookingResponse;
import horizon.example.demo.entity.AvailabilityStatus;
import horizon.example.demo.entity.GuideAvailability;
import horizon.example.demo.entity.GuideBooking;
import horizon.example.demo.entity.GuideBookingStatus;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.InvalidStatusTransitionException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.GuideAvailabilityRepository;
import horizon.example.demo.repository.GuideBookingRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.service.CommissionService;
import horizon.example.demo.service.GuideBookingService;
import horizon.example.demo.service.NotificationService;
import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GuideBookingServiceImpl implements GuideBookingService {

    private final GuideBookingRepository guideBookingRepository;
    private final TouristRepository touristRepository;
    private final TourGuideRepository tourGuideRepository;
    private final GuideAvailabilityRepository guideAvailabilityRepository;
    private final CommissionService commissionService;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public GuideBookingResponse create(CreateGuideBookingRequest request) {
        Tourist tourist = touristRepository.findById(request.getTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getTouristId()));
        TourGuide guide = tourGuideRepository.findById(request.getTourGuideId())
                .orElseThrow(() -> new ResourceNotFoundException("Guide not found: " + request.getTourGuideId()));

        GuideAvailability availability = null;
        if (request.getGuideAvailabilityId() != null) {
            availability = guideAvailabilityRepository.findById(request.getGuideAvailabilityId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Guide availability not found: " + request.getGuideAvailabilityId()));
        }

        validateAgreedPrice(guide, request.getAgreedPrice(), request.isNegotiated());

        GuideBooking booking = GuideBooking.builder()
                .tourist(tourist)
                .tourGuide(guide)
                .guideAvailability(availability)
                .scheduleDate(request.getScheduleDate())
                .agreedPrice(request.getAgreedPrice())
                .isNegotiated(request.isNegotiated())
                .status(GuideBookingStatus.REQUESTED)
                .paymentReceived(false)
                .build();

        guideBookingRepository.save(booking);
        notificationService.create(
                guide.getId(),
                "NEW_BOOKING",
                tourist.getFullName() + " requested a tour with you.");
        return toResponse(booking);
    }

    @Override
    @Transactional
    public GuideBookingResponse updateStatus(Long id, UpdateGuideBookingStatusRequest request) {
        GuideBooking booking = findEntity(id);
        GuideBookingStatus target = request.getStatus();

        if (target == GuideBookingStatus.ACCEPTED) {
            if (booking.getStatus() != GuideBookingStatus.REQUESTED) {
                throw new InvalidStatusTransitionException(
                        "Only REQUESTED guide bookings can be accepted, current status: " + booking.getStatus());
            }
            if (booking.getGuideAvailability() != null) {
                booking.getGuideAvailability().setStatus(AvailabilityStatus.BOOKED);
            }
            notificationService.create(
                    booking.getTourist().getId(),
                    "GUIDE_BOOKING_ACCEPTED",
                    booking.getTourGuide().getFullName() + " accepted your tour request.");
        } else if (target == GuideBookingStatus.DECLINED) {
            if (booking.getGuideAvailability() != null) {
                booking.getGuideAvailability().setStatus(AvailabilityStatus.OPEN);
            }
            notificationService.create(
                    booking.getTourist().getId(),
                    "GUIDE_BOOKING_DECLINED",
                    booking.getTourGuide().getFullName() + " declined your tour request.");
        } else if (target == GuideBookingStatus.COMPLETED) {
            if (booking.getStatus() != GuideBookingStatus.ACCEPTED) {
                throw new InvalidStatusTransitionException(
                        "Only ACCEPTED guide bookings can be completed, current status: " + booking.getStatus());
            }
        }

        booking.setStatus(target);
        return toResponse(booking);
    }

    @Override
    @Transactional
    public GuideBookingResponse markPaymentReceived(Long id) {
        GuideBooking booking = findEntity(id);
        booking.setPaymentReceived(true);
        commissionService.calculateForGuideBooking(booking);
        notificationService.create(
                booking.getTourist().getId(),
                "PAYMENT_RECEIVED",
                "Your cash payment for the tour with " + booking.getTourGuide().getFullName() + " was recorded.");
        return toResponse(booking);
    }

    private void validateAgreedPrice(TourGuide guide, BigDecimal agreedPrice, boolean negotiated) {
        if (agreedPrice == null || agreedPrice.signum() <= 0) {
            throw new InvalidRequestException("Agreed price must be a positive amount");
        }
        BigDecimal defaultPrice = guide.getDefaultPrice();
        if (defaultPrice == null) {
            return;
        }
        if (!negotiated) {
            if (agreedPrice.compareTo(defaultPrice) != 0) {
                throw new InvalidRequestException(
                        "Agreed price must match the guide's default price unless negotiated");
            }
            return;
        }
        BigDecimal minAllowed = defaultPrice.multiply(new BigDecimal("0.5"));
        BigDecimal maxAllowed = defaultPrice.multiply(new BigDecimal("2"));
        if (agreedPrice.compareTo(minAllowed) < 0 || agreedPrice.compareTo(maxAllowed) > 0) {
            throw new InvalidRequestException(
                    "Negotiated price must be within 50%-200% of the guide's default price");
        }
    }

    @Override
    public List<GuideBookingResponse> listByGuide(Long guideId) {
        return guideBookingRepository.findByTourGuideId(guideId).stream().map(this::toResponse).toList();
    }

    @Override
    public List<GuideBookingResponse> listByTourist(Long touristId) {
        return guideBookingRepository.findByTouristId(touristId).stream().map(this::toResponse).toList();
    }

    private GuideBooking findEntity(Long id) {
        return guideBookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Guide booking not found: " + id));
    }

    private GuideBookingResponse toResponse(GuideBooking booking) {
        return GuideBookingResponse.builder()
                .id(booking.getId())
                .touristId(booking.getTourist().getId())
                .tourGuideId(booking.getTourGuide().getId())
                .guideAvailabilityId(booking.getGuideAvailability() != null ? booking.getGuideAvailability().getId() : null)
                .scheduleDate(booking.getScheduleDate())
                .agreedPrice(booking.getAgreedPrice())
                .isNegotiated(booking.isNegotiated())
                .status(booking.getStatus())
                .paymentReceived(booking.isPaymentReceived())
                .build();
    }
}
