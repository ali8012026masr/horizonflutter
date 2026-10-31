package horizon.example.demo.dto.request;

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
public class GuideAvailabilitySearchRequest {

    private LocalDate dateFrom;
    private LocalDate dateTo;
    private String location;
}
