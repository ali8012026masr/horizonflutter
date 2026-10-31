package horizon.example.demo.service.impl;

import horizon.example.demo.dto.response.NotificationResponse;
import horizon.example.demo.entity.Notification;
import horizon.example.demo.entity.User;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.NotificationRepository;
import horizon.example.demo.repository.UserRepository;
import horizon.example.demo.service.NotificationService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public void create(Long recipientId, String type, String message) {
        User recipient = userRepository.findById(recipientId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + recipientId));

        Notification notification = Notification.builder()
                .recipient(recipient)
                .type(type)
                .message(message)
                .read(false)
                .build();

        notificationRepository.save(notification);
    }

    @Override
    public List<NotificationResponse> listForUser(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public long unreadCount(Long userId) {
        return notificationRepository.countByRecipientIdAndReadFalse(userId);
    }

    @Override
    @Transactional
    public NotificationResponse markRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found: " + notificationId));
        notification.setRead(true);
        return toResponse(notification);
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .message(notification.getMessage())
                .type(notification.getType())
                .read(notification.isRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
