package horizon.example.demo.service;

import horizon.example.demo.dto.response.NotificationResponse;
import java.util.List;

public interface NotificationService {
    void create(Long recipientId, String type, String message);
    List<NotificationResponse> listForUser(Long userId);
    long unreadCount(Long userId);
    NotificationResponse markRead(Long notificationId);
}
