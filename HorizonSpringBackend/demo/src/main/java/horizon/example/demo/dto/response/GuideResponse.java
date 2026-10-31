package horizon.example.demo.dto.response;

import horizon.example.demo.entity.UserStatus;
import horizon.example.demo.entity.VerificationStatus;
import java.math.BigDecimal;
import java.util.List;
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
public class GuideResponse {

    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private UserStatus status;
    private String nationalId;
    private String bio;
    private double ratingAvg;
    private int ratingCount;
    private boolean isAvailable;
    private VerificationStatus verificationStatus;
    private String rejectionReason;
    private List<String> languages;
    private String location;
    private int experienceYears;
    private BigDecimal defaultPrice;
    private boolean negotiable;
}
