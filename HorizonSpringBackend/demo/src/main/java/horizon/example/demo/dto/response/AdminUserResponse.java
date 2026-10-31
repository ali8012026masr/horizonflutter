package horizon.example.demo.dto.response;

import horizon.example.demo.entity.UserStatus;
import java.time.LocalDateTime;
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
public class AdminUserResponse {

    private Long id;
    private String fullName;
    private String email;
    private String role;
    private UserStatus status;
    private LocalDateTime createdAt;
}
