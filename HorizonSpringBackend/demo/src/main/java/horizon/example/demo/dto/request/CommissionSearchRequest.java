package horizon.example.demo.dto.request;

import horizon.example.demo.entity.SettlementStatus;
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
public class CommissionSearchRequest {

    private LocalDateTime dateFrom;
    private LocalDateTime dateTo;
    private SettlementStatus settlementStatus;
}
