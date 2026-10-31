package horizon.example.demo.controller;

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
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register/tourist")
    public ResponseEntity<TouristResponse> registerTourist(@Valid @RequestBody RegisterTouristRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerTourist(request));
    }

    @PostMapping("/register/provider")
    public ResponseEntity<ProviderResponse> registerProvider(@Valid @RequestBody RegisterProviderRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerProvider(request));
    }

    @PostMapping("/register/guide")
    public ResponseEntity<GuideResponse> registerGuide(@Valid @RequestBody RegisterGuideRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerGuide(request));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        return ResponseEntity.ok(authService.forgotPassword(request));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<MessageResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        return ResponseEntity.ok(authService.resetPassword(request));
    }

    @PutMapping("/change-password")
    public ResponseEntity<MessageResponse> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        return ResponseEntity.ok(authService.changePassword(CurrentUser.id(), request));
    }
}
