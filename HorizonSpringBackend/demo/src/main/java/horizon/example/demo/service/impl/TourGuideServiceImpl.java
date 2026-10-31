package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.UpdateGuideRequest;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.TourGuideService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TourGuideServiceImpl implements TourGuideService {

    private final TourGuideRepository tourGuideRepository;

    @Override
    public GuideResponse getById(Long id) {
        return toResponse(findEntity(id));
    }

    @Override
    @Transactional
    public GuideResponse update(Long id, UpdateGuideRequest request) {
        requireSelfOrAdmin(id);
        TourGuide guide = findEntity(id);

        if (request.getFullName() != null) guide.setFullName(request.getFullName());
        if (request.getPhone() != null) guide.setPhone(request.getPhone());
        if (request.getAddress() != null) guide.setAddress(request.getAddress());
        if (request.getBio() != null) guide.setBio(request.getBio());
        if (request.getIsAvailable() != null) guide.setAvailable(request.getIsAvailable());
        if (request.getLanguages() != null) guide.setLanguages(request.getLanguages());
        if (request.getLocation() != null) guide.setLocation(request.getLocation());
        if (request.getExperienceYears() != null) guide.setExperienceYears(request.getExperienceYears());
        if (request.getDefaultPrice() != null) guide.setDefaultPrice(request.getDefaultPrice());
        if (request.getNegotiable() != null) guide.setNegotiable(request.getNegotiable());

        return toResponse(guide);
    }

    @Override
    public List<GuideResponse> listAvailable(boolean available) {
        return tourGuideRepository.findByIsAvailable(available).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public void delete(Long id) {
        requireSelfOrAdmin(id);
        TourGuide guide = findEntity(id);
        guide.setStatus(UserStatus.REVOKED);
    }

    private void requireSelfOrAdmin(Long id) {
        if (!CurrentUser.isAdmin() && !CurrentUser.id().equals(id)) {
            throw new AccessDeniedException("You can only access your own guide profile");
        }
    }

    private TourGuide findEntity(Long id) {
        return tourGuideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Guide not found: " + id));
    }

    private GuideResponse toResponse(TourGuide guide) {
        return GuideResponse.builder()
                .id(guide.getId())
                .fullName(guide.getFullName())
                .email(guide.getEmail())
                .phone(guide.getPhone())
                .address(guide.getAddress())
                .status(guide.getStatus())
                .nationalId(guide.getNationalId())
                .bio(guide.getBio())
                .ratingAvg(guide.getRatingAvg())
                .ratingCount(guide.getRatingCount())
                .isAvailable(guide.isAvailable())
                .verificationStatus(guide.getVerificationStatus())
                .rejectionReason(guide.getRejectionReason())
                .languages(guide.getLanguages())
                .location(guide.getLocation())
                .experienceYears(guide.getExperienceYears())
                .defaultPrice(guide.getDefaultPrice())
                .negotiable(guide.isNegotiable())
                .build();
    }
}
