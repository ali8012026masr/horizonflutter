package horizon.example.demo.dto.request;

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
public class UpdateGuideRequest {

    private String fullName;
    private String phone;
    private String address;
    private String bio;
    private Boolean isAvailable;
    private List<String> languages;
    private String location;
    private Integer experienceYears;
    private BigDecimal defaultPrice;
    private Boolean negotiable;
}
