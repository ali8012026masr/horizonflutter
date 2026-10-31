package horizon.example.demo.dto.response;

import horizon.example.demo.entity.UserStatus;
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
public class TouristResponse {

    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private UserStatus status;
    private int loyaltyPoints;
}
