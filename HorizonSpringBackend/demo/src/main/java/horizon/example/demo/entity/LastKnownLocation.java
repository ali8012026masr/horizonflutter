package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Schema stub for future live-tracking phase. No logic populates or reads this yet. */
@Entity
@Table(name = "last_known_locations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LastKnownLocation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tour_guide_id", nullable = false)
    private TourGuide tourGuide;

    private Double latitude;

    private Double longitude;

    private LocalDateTime updatedAt;
}
