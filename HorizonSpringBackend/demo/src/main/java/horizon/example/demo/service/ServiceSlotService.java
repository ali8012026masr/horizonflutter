package horizon.example.demo.service;

import horizon.example.demo.dto.request.CreateServiceSlotRequest;
import horizon.example.demo.dto.request.ServiceSlotSearchRequest;
import horizon.example.demo.dto.request.UpdateServiceSlotRequest;
import horizon.example.demo.dto.response.ServiceSlotResponse;
import java.util.List;

public interface ServiceSlotService {
    ServiceSlotResponse create(CreateServiceSlotRequest request);
    ServiceSlotResponse update(Long id, UpdateServiceSlotRequest request);
    void cancel(Long id);
    ServiceSlotResponse getById(Long id);
    List<ServiceSlotResponse> search(ServiceSlotSearchRequest request);
    List<ServiceSlotResponse> listByProvider(Long providerId);
}
