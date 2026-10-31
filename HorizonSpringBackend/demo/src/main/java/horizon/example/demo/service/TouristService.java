package horizon.example.demo.service;

import horizon.example.demo.dto.request.UpdateTouristRequest;
import horizon.example.demo.dto.response.TouristResponse;

public interface TouristService {
    TouristResponse getById(Long id);
    TouristResponse update(Long id, UpdateTouristRequest request);
    void delete(Long id);
}
