package horizon.example.demo.controller;

import horizon.example.demo.dto.request.UpdateGuideRequest;
import horizon.example.demo.dto.response.GuideResponse;
import horizon.example.demo.service.TourGuideService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/guides")
@RequiredArgsConstructor
public class GuideController {

    private final TourGuideService tourGuideService;

    @GetMapping("/{id}")
    public GuideResponse getById(@PathVariable Long id) {
        return tourGuideService.getById(id);
    }

    @PutMapping("/{id}")
    public GuideResponse update(@PathVariable Long id, @Valid @RequestBody UpdateGuideRequest request) {
        return tourGuideService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        tourGuideService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public List<GuideResponse> list(@RequestParam(required = false) Boolean available) {
        return tourGuideService.listAvailable(available == null || available);
    }
}
