package horizon.example.demo.dto.response;

import java.math.BigDecimal;
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
public class CommissionSummaryResponse {

    private BigDecimal totalCommission;
    private BigDecimal pendingCommission;
    private BigDecimal settledCommission;
}
