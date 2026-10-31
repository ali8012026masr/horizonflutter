package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@DiscriminatorValue("SERVICE_PROVIDER")
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
public class ServiceProvider extends User {

    @Column(nullable = false)
    private String businessName;

    private String tradeLicenseNo;

    private String nationalId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ServiceCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VerificationStatus verificationStatus;

    private String rejectionReason;

    private BigDecimal commissionRate;

    @Column(nullable = false)
    private double ratingAvg;

    @Column(nullable = false)
    private int ratingCount;
}
