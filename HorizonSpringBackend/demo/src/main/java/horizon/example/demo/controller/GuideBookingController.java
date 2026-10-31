package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreateGuideBookingRequest;
import horizon.example.demo.dto.request.UpdateGuideBookingStatusRequest;
import horizon.example.demo.dto.response.GuideBookingResponse;
import horizon.example.demo.service.GuideBookingService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/guide-bookings")
@RequiredArgsConstructor
public class GuideBookingController {

    private final GuideBookingService guideBookingService;

    @PostMapping
    public ResponseEntity<GuideBookingResponse> create(@Valid @RequestBody CreateGuideBookingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(guideBookingService.create(request));
    }

    @GetMapping("/guide/{guideId}")
    public List<GuideBookingResponse> listByGuide(@PathVariable Long guideId) {
        return guideBookingService.listByGuide(guideId);
    }

    @GetMapping("/tourist/{touristId}")
    public List<GuideBookingResponse> listByTourist(@PathVariable Long touristId) {
        return guideBookingService.listByTourist(touristId);
    }

    @PutMapping("/{id}/status")
    public GuideBookingResponse updateStatus(@PathVariable Long id, @Valid @RequestBody UpdateGuideBookingStatusRequest request) {
        return guideBookingService.updateStatus(id, request);
    }

    @PutMapping("/{id}/payment-received")
    public GuideBookingResponse markPaymentReceived(@PathVariable Long id) {
        return guideBookingService.markPaymentReceived(id);
    }
}
