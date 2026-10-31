package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.ChangePasswordRequest;
import horizon.example.demo.dto.request.ForgotPasswordRequest;
import horizon.example.demo.dto.request.LoginRequest;
import horizon.example.demo.dto.request.RegisterGuideRequest;
import horizon.example.demo.dto.request.RegisterProviderRequest;
import horizon.example.demo.dto.request.RegisterTouristRequest;
import horizon.example.demo.dto.request.ResetPasswordRequest;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.dto.response.LoginResponse;
import horizon.example.demo.dto.response.MessageResponse;
import horizon.example.demo.dto.response.ProviderResponse;
import horizon.example.demo.dto.response.TouristResponse;
import horizon.example.demo.entity.*;
import horizon.example.demo.exception.DuplicateEmailException;
import horizon.example.demo.exception.EmailDeliveryException;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.PasswordResetTokenRepository;
import horizon.example.demo.repository.ServiceProviderRepository;
import horizon.example.demo.repository.TourGuideRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.repository.UserRepository;
import horizon.example.demo.security.AuthProvider;
import horizon.example.demo.security.HorizonUserDetails;
import horizon.example.demo.service.AuthService;
import horizon.example.demo.service.EmailService;
import horizon.example.demo.service.JwtService;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private static final java.math.BigDecimal DEFAULT_COMMISSION_RATE = new java.math.BigDecimal("10");
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final MessageResponse FORGOT_PASSWORD_GENERIC_RESPONSE = MessageResponse.builder()
            .message("If that email is registered, a password reset code has been sent to it.")
            .build();

    private final UserRepository userRepository;
    private final TouristRepository touristRepository;
    private final ServiceProviderRepository serviceProviderRepository;
    private final TourGuideRepository tourGuideRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthProvider authProvider;
    private final JwtService jwtService;
    private final EmailService emailService;

    @Override
    @Transactional
    public TouristResponse registerTourist(RegisterTouristRequest request) {
        assertEmailAvailable(request.getEmail());
        Tourist tourist = Tourist.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .address(request.getAddress())
                .status(UserStatus.ACTIVE)
                .loyaltyPoints(0)
                .build();
        touristRepository.save(tourist);
        return toTouristResponse(tourist);
    }

    @Override
    @Transactional
    public ProviderResponse registerProvider(RegisterProviderRequest request) {
        assertEmailAvailable(request.getEmail());
        ServiceProvider provider = ServiceProvider.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .address(request.getAddress())
                .status(UserStatus.PENDING_VERIFICATION)
                .businessName(request.getBusinessName())
                .tradeLicenseNo(request.getTradeLicenseNo())
                .nationalId(request.getNationalId())
                .commissionRate(request.getCommissionRate() != null ? request.getCommissionRate() : DEFAULT_COMMISSION_RATE)
                .category(request.getCategory())
                .verificationStatus(VerificationStatus.PENDING)
                .ratingAvg(0)
                .ratingCount(0)
                .build();
        serviceProviderRepository.save(provider);
        return toProviderResponse(provider);
    }

    @Override
    @Transactional
    public GuideResponse registerGuide(RegisterGuideRequest request) {
        assertEmailAvailable(request.getEmail());
        TourGuide guide = TourGuide.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .address(request.getAddress())
                .status(UserStatus.PENDING_VERIFICATION)
                .nationalId(request.getNationalId())
                .bio(request.getBio())
                .ratingAvg(0)
                .ratingCount(0)
                .isAvailable(true)
                .verificationStatus(VerificationStatus.PENDING)
                .languages(request.getLanguages() != null ? request.getLanguages() : List.of())
                .location(request.getLocation())
                .experienceYears(request.getExperienceYears())
                .defaultPrice(request.getDefaultPrice())
                .commissionRate(DEFAULT_COMMISSION_RATE)
                .negotiable(request.isNegotiable())
                .gpsEnabled(false)
                .build();
        tourGuideRepository.save(guide);
        return toGuideResponse(guide);
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        Authentication authentication = authProvider.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));
        User user = ((HorizonUserDetails) authentication.getPrincipal()).getUser();
        String accessToken = authentication.getCredentials().toString();
        String refreshToken = jwtService.generateRefreshToken(user.getEmail(), user.getPasswordHash());

        Object roleDetails = switch (user) {
            case Admin ignored -> null;
            case ServiceProvider p -> toProviderResponse(p);
            case TourGuide g -> toGuideResponse(g);
            case Tourist t -> toTouristResponse(t);
            default -> null;
        };

        return LoginResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(resolveRole(user))
                .roleDetails(roleDetails)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresInSeconds(jwtService.getAccessTokenExpirationMillis() / 1000)
                .build();
    }

    @Override
    @Transactional
    public MessageResponse forgotPassword(ForgotPasswordRequest request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            // Deliberately silent - same response as the found-a-user path, no leak of which emails exist.
            return FORGOT_PASSWORD_GENERIC_RESPONSE;
        }

        User user = userOpt.get();
        String code = generateResetCode();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .token(code)
                .expiresAt(LocalDateTime.now().plusMinutes(15))
                .used(false)
                .build();
        passwordResetTokenRepository.save(resetToken);

        // Never let a send failure escape this method - the caller must see the exact
        // same response whether or not the email exists, or an unconfigured/down SMTP
        // server becomes a user-enumeration oracle (found -> 503, not-found -> 200).
        try {
            emailService.sendPasswordResetCode(user.getEmail(), code);
        } catch (EmailDeliveryException e) {
            log.warn("Password reset email failed to send for user id {}: {}", user.getId(), e.getMessage());
        }

        return FORGOT_PASSWORD_GENERIC_RESPONSE;
    }

    @Override
    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new InvalidRequestException("Invalid or expired reset code"));

        if (resetToken.isUsed() || resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new InvalidRequestException("Invalid or expired reset code");
        }

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setTokensValidAfter(LocalDateTime.now());
        resetToken.setUsed(true);

        return MessageResponse.builder().message("Password reset successfully. Please log in again.").build();
    }

    @Override
    @Transactional
    public MessageResponse changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Current password is incorrect");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setTokensValidAfter(LocalDateTime.now());

        return MessageResponse.builder().message("Password changed successfully. Please log in again.").build();
    }

    private String generateResetCode() {
        int code = RANDOM.nextInt(1_000_000);
        return String.format("%06d", code);
    }

    private void assertEmailAvailable(String email) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new DuplicateEmailException("Email already registered: " + email);
        }
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

    private TouristResponse toTouristResponse(Tourist tourist) {
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
