package horizon.example.demo.controller;

import horizon.example.demo.dto.request.UpdateTouristRequest;
import horizon.example.demo.dto.response.TouristResponse;
import horizon.example.demo.service.TouristService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tourists")
@RequiredArgsConstructor
public class TouristController {

    private final TouristService touristService;

    @GetMapping("/{id}")
    public TouristResponse getById(@PathVariable Long id) {
        return touristService.getById(id);
    }

    @PutMapping("/{id}")
    public TouristResponse update(@PathVariable Long id, @Valid @RequestBody UpdateTouristRequest request) {
        return touristService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        touristService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
