package horizon.example.demo.dto.request;

import horizon.example.demo.entity.PaymentMethod;
import horizon.example.demo.entity.PaymentTxStatus;
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
public class PaymentSearchRequest {

    private LocalDateTime dateFrom;
    private LocalDateTime dateTo;
    private PaymentTxStatus status;
    private PaymentMethod method;
}
