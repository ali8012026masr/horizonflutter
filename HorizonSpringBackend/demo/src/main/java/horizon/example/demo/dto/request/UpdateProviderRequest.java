package horizon.example.demo.dto.request;

import horizon.example.demo.entity.ServiceCategory;
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
public class UpdateProviderRequest {

    private String fullName;
    private String phone;
    private String address;
    private String businessName;
    private String tradeLicenseNo;
    private ServiceCategory category;
    private BigDecimal commissionRate;
}
