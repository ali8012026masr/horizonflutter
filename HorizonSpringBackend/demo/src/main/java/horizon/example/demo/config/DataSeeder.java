package horizon.example.demo.config;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import horizon.example.demo.entity.Admin;
import horizon.example.demo.entity.AvailabilityStatus;
import horizon.example.demo.entity.GuideAvailability;
import horizon.example.demo.entity.ServiceCategory;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.ServiceSlot;
import horizon.example.demo.entity.SlotStatus;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.entity.VerificationStatus;
import horizon.example.demo.repository.AdminRepository;
import horizon.example.demo.repository.GuideAvailabilityRepository;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.repository.ServiceSlotRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.repository.UserRepository;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ServiceProviderRepository serviceProviderRepository;
    private final TourGuideRepository tourGuideRepository;
    private final TouristRepository touristRepository;
    private final AdminRepository adminRepository;
    private final ServiceSlotRepository serviceSlotRepository;
    private final GuideAvailabilityRepository guideAvailabilityRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.count() > 0) {
            return;
        }

        String hash = passwordEncoder.encode("demo1234");

        Admin admin = Admin.builder()
                .fullName("Horizon Admin")
                .email("admin@horizon.demo")
                .passwordHash(hash)
                .status(UserStatus.ACTIVE)
                .build();
        adminRepository.save(admin);

        ServiceProvider provider = ServiceProvider.builder()
                .fullName("Nabin Chandra Roy")
                .email("provider@horizon.demo")
                .passwordHash(hash)
                .status(UserStatus.ACTIVE)
                .businessName("Green Line Paribahan")
                .tradeLicenseNo("TL-2024-00123")
                .category(ServiceCategory.BUS)
                .verificationStatus(VerificationStatus.APPROVED)
                .commissionRate(new BigDecimal("10.00"))
                .ratingAvg(0)
                .ratingCount(0)
                .build();
        serviceProviderRepository.save(provider);

        TourGuide guide = TourGuide.builder()
                .fullName("Rashed Karim")
                .email("guide@horizon.demo")
                .passwordHash(hash)
                .status(UserStatus.ACTIVE)
                .nationalId("1990123456789")
                .bio("Licensed guide covering Cox's Bazar and the Sundarbans, 8 years in the field.")
                .ratingAvg(0)
                .ratingCount(0)
                .isAvailable(true)
                .verificationStatus(VerificationStatus.APPROVED)
                .languages(List.of("Bengali", "English"))
                .location("Cox's Bazar")
                .experienceYears(8)
                .defaultPrice(new BigDecimal("3500.00"))
                .negotiable(true)
                .gpsEnabled(false)
                .build();
        tourGuideRepository.save(guide);

        Tourist tourist = Tourist.builder()
                .fullName("Farhana Akter")
                .email("tourist@horizon.demo")
                .passwordHash(hash)
                .status(UserStatus.ACTIVE)
                .loyaltyPoints(0)
                .build();
        touristRepository.save(tourist);

        ServiceSlot slot = ServiceSlot.builder()
                .provider(provider)
                .category(ServiceCategory.BUS)
                .origin("Dhaka")
                .destination("Cox's Bazar")
                .startDateTime(LocalDateTime.now().plusDays(3).withHour(21).withMinute(0))
                .endDateTime(LocalDateTime.now().plusDays(4).withHour(6).withMinute(0))
                .capacity(40)
                .availableSeats(40)
                .price(new BigDecimal("1200.00"))
                .status(SlotStatus.OPEN)
                .build();
        serviceSlotRepository.save(slot);

        GuideAvailability availability = GuideAvailability.builder()
                .tourGuide(guide)
                .date(LocalDate.now().plusDays(5))
                .startTime(LocalTime.of(9, 0))
                .endTime(LocalTime.of(17, 0))
                .location("Cox's Bazar")
                .notes("Full-day beach and Himchari tour.")
                .status(AvailabilityStatus.OPEN)
                .build();
        guideAvailabilityRepository.save(availability);
    }
}
