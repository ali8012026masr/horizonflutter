package horizon.example.demo.dto.request;

import horizon.example.demo.entity.ServiceCategory;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
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
public class CreateServiceSlotRequest {

    @NotNull
    private Long providerId;

    @NotNull
    private ServiceCategory category;

    private String origin;

    private String destination;

    private String locationName;

    @NotNull
    @Future
    private LocalDateTime startDateTime;

    @NotNull
    @Future
    private LocalDateTime endDateTime;

    @Positive
    private int capacity;

    @NotNull
    @Positive
    private BigDecimal price;
}
