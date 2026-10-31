package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.UpdateUserStatusRequest;
import horizon.example.demo.dto.request.VerifyGuideRequest;
import horizon.example.demo.dto.request.VerifyProviderRequest;
import horizon.example.demo.dto.response.AdminUserResponse;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.dto.response.ProviderResponse;
import horizon.example.demo.entity.Admin;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.entity.User;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.entity.VerificationStatus;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.repository.UserRepository;
import horizon.example.demo.service.AdminService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final ServiceProviderRepository serviceProviderRepository;
    private final TourGuideRepository tourGuideRepository;
    private final UserRepository userRepository;

    @Override
    public List<ProviderResponse> listPendingProviders() {
        return serviceProviderRepository.findByVerificationStatus(VerificationStatus.PENDING).stream()
                .map(this::toProviderResponse)
                .toList();
    }

    @Override
    public List<GuideResponse> listPendingGuides() {
        return tourGuideRepository.findByVerificationStatus(VerificationStatus.PENDING).stream()
                .map(this::toGuideResponse)
                .toList();
    }

    @Override
    @Transactional
    public ProviderResponse verifyProvider(Long id, VerifyProviderRequest request) {
        ServiceProvider provider = serviceProviderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found: " + id));

        if (Boolean.TRUE.equals(request.getApproved())) {
            provider.setVerificationStatus(VerificationStatus.APPROVED);
            provider.setStatus(UserStatus.ACTIVE);
            provider.setRejectionReason(null);
        } else {
            if (request.getRejectionReason() == null || request.getRejectionReason().isBlank()) {
                throw new InvalidRequestException("rejectionReason is required when approved is false");
            }
            provider.setVerificationStatus(VerificationStatus.REJECTED);
            provider.setRejectionReason(request.getRejectionReason());
        }

        return toProviderResponse(provider);
    }

    @Override
    @Transactional
    public GuideResponse verifyGuide(Long id, VerifyGuideRequest request) {
        TourGuide guide = tourGuideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Guide not found: " + id));

        if (Boolean.TRUE.equals(request.getApproved())) {
            guide.setVerificationStatus(VerificationStatus.APPROVED);
            guide.setStatus(UserStatus.ACTIVE);
            guide.setRejectionReason(null);
        } else {
            if (request.getRejectionReason() == null || request.getRejectionReason().isBlank()) {
                throw new InvalidRequestException("rejectionReason is required when approved is false");
            }
            guide.setVerificationStatus(VerificationStatus.REJECTED);
            guide.setRejectionReason(request.getRejectionReason());
        }

        return toGuideResponse(guide);
    }

    @Override
    public List<AdminUserResponse> listUsers(String role, String status) {
        return userRepository.findAll().stream()
                .filter(user -> role == null || role.isBlank() || resolveRole(user).equalsIgnoreCase(role))
                .filter(user -> status == null || status.isBlank() || user.getStatus().name().equalsIgnoreCase(status))
                .map(this::toAdminUserResponse)
                .toList();
    }

    @Override
    @Transactional
    public AdminUserResponse updateUserStatus(Long id, UpdateUserStatusRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
        user.setStatus(request.getStatus());
        return toAdminUserResponse(user);
    }

    private String resolveRole(User user) {
        return switch (user) {
            case Admin ignored -> "ADMIN";
            case ServiceProvider ignored -> "SERVICE_PROVIDER";
            case TourGuide ignored -> "TOUR_GUIDE";
            case Tourist ignored -> "TOURIST";
            default -> "UNKNOWN";
        };
    }

    private AdminUserResponse toAdminUserResponse(User user) {
        return AdminUserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(resolveRole(user))
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .build();
    }

    private ProviderResponse toProviderResponse(ServiceProvider provider) {
        return ProviderResponse.builder()
                .id(provider.getId())
                .fullName(provider.getFullName())
                .email(provider.getEmail())
                .phone(provider.getPhone())
                .address(provider.getAddress())
                .status(provider.getStatus())
                .businessName(provider.getBusinessName())
                .tradeLicenseNo(provider.getTradeLicenseNo())
                .category(provider.getCategory())
                .verificationStatus(provider.getVerificationStatus())
                .rejectionReason(provider.getRejectionReason())
                .commissionRate(provider.getCommissionRate())
                .ratingAvg(provider.getRatingAvg())
                .ratingCount(provider.getRatingCount())
                .build();
    }

    private GuideResponse toGuideResponse(TourGuide guide) {
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
