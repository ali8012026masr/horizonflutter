package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateGuideAvailabilityRequest;
import horizon.example.demo.dto.request.GuideAvailabilitySearchRequest;
import horizon.example.demo.dto.request.UpdateGuideAvailabilityRequest;
import horizon.example.demo.dto.response.GuideAvailabilityResponse;
import horizon.example.demo.entity.AvailabilityStatus;
import horizon.example.demo.entity.GuideAvailability;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.GuideAvailabilityRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.repository.spec.GuideAvailabilitySpecifications;
import horizon.example.demo.service.GuideAvailabilityService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GuideAvailabilityServiceImpl implements GuideAvailabilityService {

    private final GuideAvailabilityRepository guideAvailabilityRepository;
    private final TourGuideRepository tourGuideRepository;

    @Override
    @Transactional
    public GuideAvailabilityResponse create(CreateGuideAvailabilityRequest request) {
        TourGuide guide = tourGuideRepository.findById(request.getTourGuideId())
                .orElseThrow(() -> new ResourceNotFoundException("Guide not found: " + request.getTourGuideId()));

        GuideAvailability availability = GuideAvailability.builder()
                .tourGuide(guide)
                .date(request.getDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .location(request.getLocation())
                .notes(request.getNotes())
                .status(AvailabilityStatus.OPEN)
                .build();

        guideAvailabilityRepository.save(availability);
        return toResponse(availability);
    }

    @Override
    @Transactional
    public GuideAvailabilityResponse update(Long id, UpdateGuideAvailabilityRequest request) {
        GuideAvailability availability = findEntity(id);

        if (request.getDate() != null) availability.setDate(request.getDate());
        if (request.getStartTime() != null) availability.setStartTime(request.getStartTime());
        if (request.getEndTime() != null) availability.setEndTime(request.getEndTime());
        if (request.getLocation() != null) availability.setLocation(request.getLocation());
        if (request.getNotes() != null) availability.setNotes(request.getNotes());
        if (request.getStatus() != null) availability.setStatus(request.getStatus());

        return toResponse(availability);
    }

    @Override
    @Transactional
    public void cancel(Long id) {
        GuideAvailability availability = findEntity(id);
        availability.setStatus(AvailabilityStatus.CANCELLED);
    }

    @Override
    public List<GuideAvailabilityResponse> search(GuideAvailabilitySearchRequest request) {
        return guideAvailabilityRepository.findAll(GuideAvailabilitySpecifications.fromSearch(request)).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<GuideAvailabilityResponse> listByGuide(Long guideId) {
        return guideAvailabilityRepository.findByTourGuideId(guideId).stream()
                .map(this::toResponse)
                .toList();
    }

    private GuideAvailability findEntity(Long id) {
        return guideAvailabilityRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Guide availability not found: " + id));
    }

    private GuideAvailabilityResponse toResponse(GuideAvailability availability) {
        return GuideAvailabilityResponse.builder()
                .id(availability.getId())
                .tourGuideId(availability.getTourGuide().getId())
                .tourGuideName(availability.getTourGuide().getFullName())
                .date(availability.getDate())
                .startTime(availability.getStartTime())
                .endTime(availability.getEndTime())
                .location(availability.getLocation())
                .notes(availability.getNotes())
                .status(availability.getStatus())
                .tourGuideRatingAvg(availability.getTourGuide().getRatingAvg())
                .tourGuideRatingCount(availability.getTourGuide().getRatingCount())
                .build();
    }
}
