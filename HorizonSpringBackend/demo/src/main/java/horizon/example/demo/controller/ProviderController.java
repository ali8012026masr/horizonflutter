package horizon.example.demo.controller;

import horizon.example.demo.dto.request.UpdateProviderRequest;
import horizon.example.demo.dto.response.CommissionResponse;
import horizon.example.demo.dto.response.ProviderResponse;
import horizon.example.demo.service.CommissionService;
import horizon.example.demo.service.ServiceProviderService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/providers")
@RequiredArgsConstructor
public class ProviderController {

    private final ServiceProviderService serviceProviderService;
    private final CommissionService commissionService;

    @GetMapping("/{id}")
    public ProviderResponse getById(@PathVariable Long id) {
        return serviceProviderService.getById(id);
    }

    @PutMapping("/{id}")
    public ProviderResponse update(@PathVariable Long id, @Valid @RequestBody UpdateProviderRequest request) {
        return serviceProviderService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        serviceProviderService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/commissions")
    public List<CommissionResponse> listCommissions(@PathVariable Long id) {
        return commissionService.listByProvider(id);
    }
}
