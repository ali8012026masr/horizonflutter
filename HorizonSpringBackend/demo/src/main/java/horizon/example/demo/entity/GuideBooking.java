package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "guide_bookings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuideBooking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tourist_id", nullable = false)
    private Tourist tourist;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tour_guide_id", nullable = false)
    private TourGuide tourGuide;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "guide_availability_id")
    private GuideAvailability guideAvailability;

    @Column(nullable = false)
    private LocalDate scheduleDate;

    @Column(nullable = false)
    private BigDecimal agreedPrice;

    @Column(nullable = false)
    private boolean isNegotiated;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GuideBookingStatus status;

    @Column(nullable = false)
    private boolean paymentReceived;
}
