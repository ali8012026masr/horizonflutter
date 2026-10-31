package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.UpdateTouristRequest;
import horizon.example.demo.dto.response.TouristResponse;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.TouristService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TouristServiceImpl implements TouristService {

    private final TouristRepository touristRepository;

    @Override
    public TouristResponse getById(Long id) {
        requireSelfOrAdmin(id);
        return toResponse(findEntity(id));
    }

    @Override
    @Transactional
    public TouristResponse update(Long id, UpdateTouristRequest request) {
        requireSelfOrAdmin(id);
        Tourist tourist = findEntity(id);

        if (request.getFullName() != null) tourist.setFullName(request.getFullName());
        if (request.getPhone() != null) tourist.setPhone(request.getPhone());
        if (request.getAddress() != null) tourist.setAddress(request.getAddress());

        return toResponse(tourist);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        requireSelfOrAdmin(id);
        Tourist tourist = findEntity(id);
        tourist.setStatus(UserStatus.REVOKED);
    }

    private void requireSelfOrAdmin(Long id) {
        if (!CurrentUser.isAdmin() && !CurrentUser.id().equals(id)) {
            throw new AccessDeniedException("You can only access your own tourist profile");
        }
    }

    private Tourist findEntity(Long id) {
        return touristRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + id));
    }

    private TouristResponse toResponse(Tourist tourist) {
        return TouristResponse.builder()
                .id(tourist.getId())
                .fullName(tourist.getFullName())
                .email(tourist.getEmail())
                .phone(tourist.getPhone())
                .address(tourist.getAddress())
                .status(tourist.getStatus())
                .loyaltyPoints(tourist.getLoyaltyPoints())
                .build();
    }
}
