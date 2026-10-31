package horizon.example.demo.dto.request;

import horizon.example.demo.entity.GuideBookingStatus;
import jakarta.validation.constraints.NotNull;
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
public class UpdateGuideBookingStatusRequest {

    @NotNull
    private GuideBookingStatus status;
}
