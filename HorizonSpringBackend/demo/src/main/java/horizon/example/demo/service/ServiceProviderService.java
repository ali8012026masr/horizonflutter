package horizon.example.demo.service;

import horizon.example.demo.dto.request.UpdateProviderRequest;
import horizon.example.demo.dto.response.ProviderResponse;

public interface ServiceProviderService {
    ProviderResponse getById(Long id);
    ProviderResponse update(Long id, UpdateProviderRequest request);
    void delete(Long id);
}
