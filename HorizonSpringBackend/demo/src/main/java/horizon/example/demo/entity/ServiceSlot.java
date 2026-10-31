package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Transport categories (BUS, MICROBUS, LAUNCH, TRAIN, AIRPLANE, SHIP) require origin+destination.
 * Non-transport categories (HOTEL, RESORT, CONVENTION_CENTER, BUFFET, AMUSEMENT_PARK) require locationName.
 * Enforced in ServiceSlotService, not at the DB level.
 */
@Entity
@Table(name = "service_slots")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private ServiceProvider provider;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ServiceCategory category;

    private String origin;

    private String destination;

    private String locationName;

    @Column(nullable = false)
    private LocalDateTime startDateTime;

    @Column(nullable = false)
    private LocalDateTime endDateTime;

    @Column(nullable = false)
    private int capacity;

    @Column(nullable = false)
    private int availableSeats;

    @Column(nullable = false)
    private BigDecimal price;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SlotStatus status;
}
