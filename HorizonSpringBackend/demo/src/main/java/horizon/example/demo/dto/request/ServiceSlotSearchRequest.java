package horizon.example.demo.dto.request;

import horizon.example.demo.entity.ServiceCategory;
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
public class ServiceSlotSearchRequest {

    private ServiceCategory category;
    private String origin;
    private String destination;
    private String locationName;
    private LocalDateTime dateFrom;
    private LocalDateTime dateTo;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
}
