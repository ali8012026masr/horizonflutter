package horizon.example.demo.dto.response;

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
public class LoginResponse {

    private Long id;
    private String fullName;
    private String email;
    private String role;

    /** Role-specific summary: verificationStatus for provider/guide, loyaltyPoints for tourist, etc. */
    private Object roleDetails;

    private String accessToken;
    private String refreshToken;
    private long expiresInSeconds;
}
