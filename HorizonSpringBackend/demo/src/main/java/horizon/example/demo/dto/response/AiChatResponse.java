package horizon.example.demo.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * actionType is one of FILTER_SLOTS / RECOMMEND_BUNDLE / RECOMMEND_GROUP_BUNDLE / NONE.
 * actionPayloadJson is model output and must never be trusted as-is - any slot/guide
 * id inside it is re-validated against the live catalog in
 * {@link horizon.example.demo.controller.AiChatController#validateAgainstCatalog}
 * before this object is returned to the frontend.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiChatResponse {
    private String replyText;
    private String actionType;
    private String actionPayloadJson;
}
