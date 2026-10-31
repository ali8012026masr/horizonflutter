package horizon.example.demo.dto.response;

import java.time.LocalDateTime;
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
public class GroupResponse {

    private Long id;
    private String groupName;
    private Long createdByTouristId;
    private String joinCode;
    private Long bookingId;
    private LocalDateTime createdAt;
    private List<GroupMemberResponse> members;
}
