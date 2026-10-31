package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.UpdateLocationRequest;
import horizon.example.demo.dto.response.LocationResponse;
import horizon.example.demo.entity.GuideBookingStatus;
import horizon.example.demo.entity.LastKnownLocation;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.GuideBookingRepository;
import horizon.example.demo.repository.LastKnownLocationRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.LocationService;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LocationServiceImpl implements LocationService {

    private final LastKnownLocationRepository lastKnownLocationRepository;
    private final TourGuideRepository tourGuideRepository;
    private final GuideBookingRepository guideBookingRepository;

    @Override
    @Transactional
    public LocationResponse updateLocation(Long tourGuideId, UpdateLocationRequest request) {
        if (!CurrentUser.id().equals(tourGuideId)) {
            throw new AccessDeniedException("A guide can only push their own location");
        }

        LastKnownLocation location = lastKnownLocationRepository.findByTourGuideId(tourGuideId)
                .orElseGet(() -> {
                    TourGuide guide = tourGuideRepository.findById(tourGuideId)
                            .orElseThrow(() -> new ResourceNotFoundException("Guide not found: " + tourGuideId));
                    return LastKnownLocation.builder().tourGuide(guide).build();
                });

        location.setLatitude(request.getLatitude());
        location.setLongitude(request.getLongitude());
        location.setUpdatedAt(LocalDateTime.now());
        lastKnownLocationRepository.save(location);

        return toResponse(location);
    }

    @Override
    public LocationResponse getLocation(Long tourGuideId) {
        Long currentUserId = CurrentUser.id();
        boolean isTheGuideThemself = currentUserId.equals(tourGuideId);
        boolean hasAcceptedBookingWithGuide = guideBookingRepository.findByTouristId(currentUserId).stream()
                .anyMatch(booking -> booking.getTourGuide().getId().equals(tourGuideId)
                        && booking.getStatus() == GuideBookingStatus.ACCEPTED);

        if (!isTheGuideThemself && !hasAcceptedBookingWithGuide) {
            throw new AccessDeniedException("Only the guide or a tourist with an accepted booking can view this location");
        }

        LastKnownLocation location = lastKnownLocationRepository.findByTourGuideId(tourGuideId)
                .orElseThrow(() -> new ResourceNotFoundException("No location shared yet for guide: " + tourGuideId));
        return toResponse(location);
    }

    private LocationResponse toResponse(LastKnownLocation location) {
        return LocationResponse.builder()
                .tourGuideId(location.getTourGuide().getId())
                .latitude(location.getLatitude())
                .longitude(location.getLongitude())
                .updatedAt(location.getUpdatedAt())
                .build();
    }
}
