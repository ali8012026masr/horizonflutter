package horizon.example.demo.controller;

import horizon.example.demo.dto.request.CreatePaymentRequest;
import horizon.example.demo.dto.request.UpdatePaymentStatusRequest;
import horizon.example.demo.dto.response.PaymentResponse;
import horizon.example.demo.service.PaymentService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping
    public ResponseEntity<PaymentResponse> create(@Valid @RequestBody CreatePaymentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(paymentService.create(request));
    }

    @GetMapping("/{id}")
    public PaymentResponse getById(@PathVariable Long id) {
        return paymentService.getById(id);
    }

    @GetMapping("/booking/{bookingId}")
    public List<PaymentResponse> listByBooking(@PathVariable Long bookingId) {
        return paymentService.listByBooking(bookingId);
    }

    @PutMapping("/{id}/status")
    public PaymentResponse updateStatus(@PathVariable Long id, @Valid @RequestBody UpdatePaymentStatusRequest request) {
        return paymentService.updateStatus(id, request);
    }
}
