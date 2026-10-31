package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreateServiceSlotRequest;
import horizon.example.demo.dto.request.ServiceSlotSearchRequest;
import horizon.example.demo.dto.request.UpdateServiceSlotRequest;
import horizon.example.demo.dto.response.ServiceSlotResponse;
import horizon.example.demo.entity.ServiceCategory;
import horizon.example.demo.service.ServiceSlotService;
import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/slots")
@RequiredArgsConstructor
public class ServiceSlotController {

    private final ServiceSlotService serviceSlotService;

    @PostMapping
    public ResponseEntity<ServiceSlotResponse> create(@Valid @RequestBody CreateServiceSlotRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(serviceSlotService.create(request));
    }

    @PutMapping("/{id}")
    public ServiceSlotResponse update(@PathVariable Long id, @Valid @RequestBody UpdateServiceSlotRequest request) {
        return serviceSlotService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        serviceSlotService.cancel(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    public ServiceSlotResponse getById(@PathVariable Long id) {
        return serviceSlotService.getById(id);
    }

    @GetMapping("/search")
    public List<ServiceSlotResponse> search(
            @RequestParam(required = false) ServiceCategory category,
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String destination,
            @RequestParam(required = false) String locationName,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dateTo,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice) {
        ServiceSlotSearchRequest request = ServiceSlotSearchRequest.builder()
                .category(category)
                .origin(origin)
                .destination(destination)
                .locationName(locationName)
                .dateFrom(dateFrom)
                .dateTo(dateTo)
                .minPrice(minPrice)
                .maxPrice(maxPrice)
                .build();
        return serviceSlotService.search(request);
    }

    @GetMapping("/provider/{providerId}")
    public List<ServiceSlotResponse> listByProvider(@PathVariable Long providerId) {
        return serviceSlotService.listByProvider(providerId);
    }
}
