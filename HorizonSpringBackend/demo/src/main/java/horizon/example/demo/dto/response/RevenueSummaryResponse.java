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
public class RevenueSummaryResponse {

    private BigDecimal totalRevenue;
    private BigDecimal totalCommission;
    private long paymentCount;
}
