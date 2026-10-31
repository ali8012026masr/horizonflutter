package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreateBookingRequest;
import horizon.example.demo.dto.request.UpdateBookingStatusRequest;
import horizon.example.demo.dto.response.BookingResponse;
import horizon.example.demo.service.BookingService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    public ResponseEntity<BookingResponse> create(@Valid @RequestBody CreateBookingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(bookingService.create(request));
    }

    @GetMapping("/tourist/{touristId}")
    public List<BookingResponse> listByTourist(@PathVariable Long touristId) {
        return bookingService.listByTourist(touristId);
    }

    @GetMapping("/provider/{providerId}")
    public List<BookingResponse> listByProvider(@PathVariable Long providerId) {
        return bookingService.listByProvider(providerId);
    }

    @PutMapping("/{id}/status")
    public BookingResponse updateStatus(@PathVariable Long id, @Valid @RequestBody UpdateBookingStatusRequest request) {
        return bookingService.updateStatus(id, request);
    }
}
