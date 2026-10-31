package horizon.example.demo.dto.response;

import horizon.example.demo.entity.AvailabilityStatus;
import java.time.LocalDate;
import java.time.LocalTime;
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
public class GuideAvailabilityResponse {

    private Long id;
    private Long tourGuideId;
    private String tourGuideName;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private String location;
    private String notes;
    private AvailabilityStatus status;
    private double tourGuideRatingAvg;
    private int tourGuideRatingCount;
}
