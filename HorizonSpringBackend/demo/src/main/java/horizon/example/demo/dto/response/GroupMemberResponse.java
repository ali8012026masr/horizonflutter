package horizon.example.demo.dto.response;

import horizon.example.demo.entity.GroupMemberStatus;
import java.math.BigDecimal;
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
public class GroupMemberResponse {

    private Long id;
    private Long touristId;
    private String touristName;
    private GroupMemberStatus status;
    private LocalDateTime joinedAt;
    private BigDecimal amountOwed;
    private boolean paid;
}
