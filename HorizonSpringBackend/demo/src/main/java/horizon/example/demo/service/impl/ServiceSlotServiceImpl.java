package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateServiceSlotRequest;
import horizon.example.demo.dto.request.ServiceSlotSearchRequest;
import horizon.example.demo.dto.request.UpdateServiceSlotRequest;
import horizon.example.demo.dto.response.ServiceSlotResponse;
import horizon.example.demo.entity.ServiceCategory;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.ServiceSlot;
import horizon.example.demo.entity.SlotStatus;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.repository.ServiceSlotRepository;
import horizon.example.demo.repository.spec.ServiceSlotSpecifications;
import horizon.example.demo.service.ServiceSlotService;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ServiceSlotServiceImpl implements ServiceSlotService {

    private static final Set<ServiceCategory> TRANSPORT_CATEGORIES = EnumSet.of(
            ServiceCategory.BUS, ServiceCategory.MICROBUS, ServiceCategory.LAUNCH,
            ServiceCategory.TRAIN, ServiceCategory.AIRPLANE, ServiceCategory.SHIP);

    private final ServiceSlotRepository serviceSlotRepository;
    private final ServiceProviderRepository serviceProviderRepository;

    @Override
    @Transactional
    public ServiceSlotResponse create(CreateServiceSlotRequest request) {
        ServiceProvider provider = serviceProviderRepository.findById(request.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found: " + request.getProviderId()));

        validateLocationFields(request.getCategory(), request.getOrigin(), request.getDestination(), request.getLocationName());

        ServiceSlot slot = ServiceSlot.builder()
                .provider(provider)
                .category(request.getCategory())
                .origin(request.getOrigin())
                .destination(request.getDestination())
                .locationName(request.getLocationName())
                .startDateTime(request.getStartDateTime())
                .endDateTime(request.getEndDateTime())
                .capacity(request.getCapacity())
                .availableSeats(request.getCapacity())
                .price(request.getPrice())
                .status(SlotStatus.OPEN)
                .build();

        serviceSlotRepository.save(slot);
        return toResponse(slot);
    }

    @Override
    @Transactional
    public ServiceSlotResponse update(Long id, UpdateServiceSlotRequest request) {
        ServiceSlot slot = findEntity(id);

        if (request.getOrigin() != null) slot.setOrigin(request.getOrigin());
        if (request.getDestination() != null) slot.setDestination(request.getDestination());
        if (request.getLocationName() != null) slot.setLocationName(request.getLocationName());
        if (request.getStartDateTime() != null) slot.setStartDateTime(request.getStartDateTime());
        if (request.getEndDateTime() != null) slot.setEndDateTime(request.getEndDateTime());
        if (request.getCapacity() != null) slot.setCapacity(request.getCapacity());
        if (request.getPrice() != null) slot.setPrice(request.getPrice());
        if (request.getStatus() != null) slot.setStatus(request.getStatus());

        validateLocationFields(slot.getCategory(), slot.getOrigin(), slot.getDestination(), slot.getLocationName());

        return toResponse(slot);
    }

    @Override
    @Transactional
    public void cancel(Long id) {
        ServiceSlot slot = findEntity(id);
        slot.setStatus(SlotStatus.CANCELLED);
    }

    @Override
    public ServiceSlotResponse getById(Long id) {
        return toResponse(findEntity(id));
    }

    @Override
    public List<ServiceSlotResponse> search(ServiceSlotSearchRequest request) {
        return serviceSlotRepository.findAll(ServiceSlotSpecifications.fromSearch(request)).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<ServiceSlotResponse> listByProvider(Long providerId) {
        return serviceSlotRepository.findByProviderId(providerId).stream()
                .map(this::toResponse)
                .toList();
    }

    private void validateLocationFields(ServiceCategory category, String origin, String destination, String locationName) {
        if (TRANSPORT_CATEGORIES.contains(category)) {
            if (origin == null || origin.isBlank() || destination == null || destination.isBlank()) {
                throw new InvalidRequestException("Transport category " + category + " requires both origin and destination");
            }
        } else {
            if (locationName == null || locationName.isBlank()) {
                throw new InvalidRequestException("Non-transport category " + category + " requires locationName");
            }
        }
    }

    private ServiceSlot findEntity(Long id) {
        return serviceSlotRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Service slot not found: " + id));
    }

    private ServiceSlotResponse toResponse(ServiceSlot slot) {
        return ServiceSlotResponse.builder()
                .id(slot.getId())
                .providerId(slot.getProvider().getId())
                .providerBusinessName(slot.getProvider().getBusinessName())
                .category(slot.getCategory())
                .origin(slot.getOrigin())
                .destination(slot.getDestination())
                .locationName(slot.getLocationName())
                .startDateTime(slot.getStartDateTime())
                .endDateTime(slot.getEndDateTime())
                .capacity(slot.getCapacity())
                .availableSeats(slot.getAvailableSeats())
                .price(slot.getPrice())
                .status(slot.getStatus())
                .providerRatingAvg(slot.getProvider().getRatingAvg())
                .providerRatingCount(slot.getProvider().getRatingCount())
                .build();
    }
}
