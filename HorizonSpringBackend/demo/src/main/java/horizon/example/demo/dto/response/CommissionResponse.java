package horizon.example.demo.dto.response;

import horizon.example.demo.entity.SettlementStatus;
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
public class CommissionResponse {

    private Long id;
    private Long bookingId;
    private String providerName;
    private String serviceCategory;
    private BigDecimal percentage;
    private BigDecimal amount;
    private LocalDateTime calculatedDate;
    private SettlementStatus settlementStatus;
}
