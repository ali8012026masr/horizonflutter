package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.UpdateProviderRequest;
import horizon.example.demo.dto.response.ProviderResponse;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.ServiceProviderService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ServiceProviderServiceImpl implements ServiceProviderService {

    private final ServiceProviderRepository serviceProviderRepository;

    @Override
    public ProviderResponse getById(Long id) {
        return toResponse(findEntity(id));
    }

    @Override
    @Transactional
    public ProviderResponse update(Long id, UpdateProviderRequest request) {
        requireSelfOrAdmin(id);
        ServiceProvider provider = findEntity(id);

        if (request.getFullName() != null) provider.setFullName(request.getFullName());
        if (request.getPhone() != null) provider.setPhone(request.getPhone());
        if (request.getAddress() != null) provider.setAddress(request.getAddress());
        if (request.getBusinessName() != null) provider.setBusinessName(request.getBusinessName());
        if (request.getTradeLicenseNo() != null) provider.setTradeLicenseNo(request.getTradeLicenseNo());
        if (request.getCategory() != null) provider.setCategory(request.getCategory());
        if (request.getCommissionRate() != null) provider.setCommissionRate(request.getCommissionRate());

        return toResponse(provider);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        requireSelfOrAdmin(id);
        ServiceProvider provider = findEntity(id);
        provider.setStatus(UserStatus.REVOKED);
    }

    private void requireSelfOrAdmin(Long id) {
        if (!CurrentUser.isAdmin() && !CurrentUser.id().equals(id)) {
            throw new AccessDeniedException("You can only access your own provider profile");
        }
    }

    private ServiceProvider findEntity(Long id) {
        return serviceProviderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found: " + id));
    }

    private ProviderResponse toResponse(ServiceProvider provider) {
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
}
