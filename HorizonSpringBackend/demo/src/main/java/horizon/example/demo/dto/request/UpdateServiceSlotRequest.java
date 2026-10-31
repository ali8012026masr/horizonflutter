package horizon.example.demo.dto.request;

import horizon.example.demo.entity.SlotStatus;
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
public class UpdateServiceSlotRequest {

    private String origin;
    private String destination;
    private String locationName;
    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;
    private Integer capacity;
    private BigDecimal price;
    private SlotStatus status;
}
