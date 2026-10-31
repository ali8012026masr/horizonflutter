package horizon.example.demo.dto.request;

import java.util.List;
import lombok.Data;

@Data
public class AiChatRequest {

    private String userMessage;
    private List<ChatMessage> history;

    @Data
    public static class ChatMessage {
        private String role; // "user" or "model"
        private String text;
    }
}
