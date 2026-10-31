package horizon.example.demo.controller;

import horizon.example.demo.dto.request.UpdateLocationRequest;
import horizon.example.demo.dto.response.LocationResponse;
import horizon.example.demo.service.LocationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/guides")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @PutMapping("/{id}/location")
    public LocationResponse updateLocation(@PathVariable Long id, @Valid @RequestBody UpdateLocationRequest request) {
        return locationService.updateLocation(id, request);
    }

    @GetMapping("/{id}/location")
    public LocationResponse getLocation(@PathVariable Long id) {
        return locationService.getLocation(id);
    }
}
