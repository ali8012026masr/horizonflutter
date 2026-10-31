package horizon.example.demo.dto.response;

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
public class ServiceRatingResponse {

    private Long id;
    private Long bookingId;
    private Long touristId;
    private Long providerId;
    private int score;
    private String comment;
    private LocalDateTime ratedDate;
}
