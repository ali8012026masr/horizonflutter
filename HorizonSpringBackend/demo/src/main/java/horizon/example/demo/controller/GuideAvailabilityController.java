package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreateGuideAvailabilityRequest;
import horizon.example.demo.dto.request.GuideAvailabilitySearchRequest;
import horizon.example.demo.dto.request.UpdateGuideAvailabilityRequest;
import horizon.example.demo.dto.response.GuideAvailabilityResponse;
import horizon.example.demo.service.GuideAvailabilityService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/guide-availability")
@RequiredArgsConstructor
public class GuideAvailabilityController {

    private final GuideAvailabilityService guideAvailabilityService;

    @PostMapping
    public ResponseEntity<GuideAvailabilityResponse> create(@Valid @RequestBody CreateGuideAvailabilityRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(guideAvailabilityService.create(request));
    }

    @PutMapping("/{id}")
    public GuideAvailabilityResponse update(@PathVariable Long id, @Valid @RequestBody UpdateGuideAvailabilityRequest request) {
        return guideAvailabilityService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        guideAvailabilityService.cancel(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public List<GuideAvailabilityResponse> search(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
            @RequestParam(required = false) String location) {
        GuideAvailabilitySearchRequest request = GuideAvailabilitySearchRequest.builder()
                .dateFrom(dateFrom)
                .dateTo(dateTo)
                .location(location)
                .build();
        return guideAvailabilityService.search(request);
    }

    @GetMapping("/guide/{guideId}")
    public List<GuideAvailabilityResponse> listByGuide(@PathVariable Long guideId) {
        return guideAvailabilityService.listByGuide(guideId);
    }
}
