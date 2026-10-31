package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@DiscriminatorValue("TOUR_GUIDE")
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
public class TourGuide extends User {

    private String nationalId;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(nullable = false)
    private double ratingAvg;

    @Column(nullable = false)
    private int ratingCount;

    @Column(nullable = false)
    @Builder.Default
    private boolean isAvailable = true;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VerificationStatus verificationStatus;

    private String rejectionReason;

    @ElementCollection
    @CollectionTable(name = "guide_languages", joinColumns = @JoinColumn(name = "tour_guide_id"))
    @Column(name = "language")
    @Builder.Default
    private List<String> languages = new ArrayList<>();

    private String location;

    @Column(nullable = false)
    private int experienceYears;

    private BigDecimal defaultPrice;

    private BigDecimal commissionRate;

    @Column(nullable = false)
    @Builder.Default
    private boolean negotiable = true;

    @Column(nullable = false)
    @Builder.Default
    private boolean gpsEnabled = false;
}
