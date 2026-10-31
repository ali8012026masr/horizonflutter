package horizon.example.demo.service;

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

public interface AuthService {
    TouristResponse registerTourist(RegisterTouristRequest request);
    ProviderResponse registerProvider(RegisterProviderRequest request);
    GuideResponse registerGuide(RegisterGuideRequest request);

    LoginResponse login(LoginRequest request);

    /** Always returns the same generic response, whether or not the email is registered - avoids user enumeration. */
    MessageResponse forgotPassword(ForgotPasswordRequest request);

    MessageResponse resetPassword(ResetPasswordRequest request);

    MessageResponse changePassword(Long userId, ChangePasswordRequest request);
}
