package horizon.example.demo.dto.response;

import horizon.example.demo.entity.ServiceCategory;
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
public class ServiceSlotResponse {

    private Long id;
    private Long providerId;
    private String providerBusinessName;
    private ServiceCategory category;
    private String origin;
    private String destination;
    private String locationName;
    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;
    private int capacity;
    private int availableSeats;
    private BigDecimal price;
    private SlotStatus status;
    private double providerRatingAvg;
    private int providerRatingCount;
}
