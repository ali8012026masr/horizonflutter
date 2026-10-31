package horizon.example.demo.dto.response;

import horizon.example.demo.entity.PaymentMethod;
import horizon.example.demo.entity.PaymentTxStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentResponse {

    private Long id;
    private Long bookingId;
    private Long guideBookingId;
    private BigDecimal amount;
    private PaymentMethod method;
    private PaymentTxStatus status;
    private LocalDateTime transactionDate;
}
