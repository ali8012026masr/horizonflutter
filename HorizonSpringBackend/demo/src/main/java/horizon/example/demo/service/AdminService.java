package horizon.example.demo.service;

import horizon.example.demo.dto.request.UpdateUserStatusRequest;
import horizon.example.demo.dto.request.VerifyGuideRequest;
import horizon.example.demo.dto.request.VerifyProviderRequest;
import horizon.example.demo.dto.response.AdminUserResponse;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.dto.response.ProviderResponse;
import java.util.List;

public interface AdminService {
    List<ProviderResponse> listPendingProviders();
    List<GuideResponse> listPendingGuides();
    ProviderResponse verifyProvider(Long id, VerifyProviderRequest request);
    GuideResponse verifyGuide(Long id, VerifyGuideRequest request);
    List<AdminUserResponse> listUsers(String role, String status);
    AdminUserResponse updateUserStatus(Long id, UpdateUserStatusRequest request);
}
