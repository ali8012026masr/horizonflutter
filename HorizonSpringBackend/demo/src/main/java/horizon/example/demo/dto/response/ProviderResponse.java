package horizon.example.demo.dto.response;

import horizon.example.demo.entity.ServiceCategory;
import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.entity.VerificationStatus;
import java.math.BigDecimal;
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
public class ProviderResponse {

    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private UserStatus status;
    private String businessName;
    private String tradeLicenseNo;
    private ServiceCategory category;
    private VerificationStatus verificationStatus;
    private String rejectionReason;
    private BigDecimal commissionRate;
    private double ratingAvg;
    private int ratingCount;
}
