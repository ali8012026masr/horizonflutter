package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.CreateServiceRatingRequest;
import horizon.example.demo.dto.response.ServiceRatingResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.ServiceRating;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.BookingRepository;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.repository.ServiceRatingRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.service.ServiceRatingService;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ServiceRatingServiceImpl implements ServiceRatingService {

    private final ServiceRatingRepository serviceRatingRepository;
    private final BookingRepository bookingRepository;
    private final TouristRepository touristRepository;
    private final ServiceProviderRepository serviceProviderRepository;

    @Override
    @Transactional
    public ServiceRatingResponse create(CreateServiceRatingRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + request.getBookingId()));
        Tourist tourist = touristRepository.findById(request.getTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getTouristId()));
        ServiceProvider provider = serviceProviderRepository.findById(request.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found: " + request.getProviderId()));

        ServiceRating rating = ServiceRating.builder()
                .booking(booking)
                .tourist(tourist)
                .provider(provider)
                .score(request.getScore())
                .comment(request.getComment())
                .ratedDate(LocalDateTime.now())
                .build();
        serviceRatingRepository.save(rating);

        recalculateProviderRating(provider);

        return toResponse(rating);
    }

    @Override
    public List<ServiceRatingResponse> listByProvider(Long providerId) {
        return serviceRatingRepository.findByProviderId(providerId).stream().map(this::toResponse).toList();
    }

    private void recalculateProviderRating(ServiceProvider provider) {
        List<ServiceRating> ratings = serviceRatingRepository.findByProviderId(provider.getId());
        int count = ratings.size();
        double avg = ratings.stream().mapToInt(ServiceRating::getScore).average().orElse(0);
        provider.setRatingCount(count);
        provider.setRatingAvg(avg);
    }

    private ServiceRatingResponse toResponse(ServiceRating rating) {
        return ServiceRatingResponse.builder()
                .id(rating.getId())
                .bookingId(rating.getBooking().getId())
                .touristId(rating.getTourist().getId())
                .providerId(rating.getProvider().getId())
                .score(rating.getScore())
                .comment(rating.getComment())
                .ratedDate(rating.getRatedDate())
                .build();
    }
}
