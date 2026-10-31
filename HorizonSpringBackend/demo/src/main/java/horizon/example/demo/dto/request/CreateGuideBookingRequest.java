package horizon.example.demo.dto.request;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
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
public class CreateGuideBookingRequest {

    @NotNull
    private Long touristId;

    @NotNull
    private Long tourGuideId;

    private Long guideAvailabilityId;

    @NotNull
    private LocalDate scheduleDate;

    @NotNull
    private BigDecimal agreedPrice;

    private boolean isNegotiated;
}
