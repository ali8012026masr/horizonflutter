package horizon.example.demo.dto.response;

import horizon.example.demo.entity.GuideBookingStatus;
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
public class GuideBookingResponse {

    private Long id;
    private Long touristId;
    private Long tourGuideId;
    private Long guideAvailabilityId;
    private LocalDate scheduleDate;
    private BigDecimal agreedPrice;
    private boolean isNegotiated;
    private GuideBookingStatus status;
    private boolean paymentReceived;
}
