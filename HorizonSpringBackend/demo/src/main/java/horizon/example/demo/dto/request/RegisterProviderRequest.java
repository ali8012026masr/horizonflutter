package horizon.example.demo.dto.request;

import horizon.example.demo.entity.ServiceCategory;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
public class RegisterProviderRequest {

    @NotBlank
    private String fullName;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;

    private String phone;

    private String address;

    @NotBlank
    private String businessName;

    private String tradeLicenseNo;

    private String nationalId;

    private BigDecimal commissionRate;

    @NotNull
    private ServiceCategory category;
}
