package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.SendGroupMessageRequest;
import horizon.example.demo.dto.response.GroupMessageResponse;
import horizon.example.demo.entity.Group;
import horizon.example.demo.entity.GroupMemberStatus;
import horizon.example.demo.entity.GroupMessage;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.exception.InvalidRequestException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.GroupMemberRepository;
import horizon.example.demo.repository.GroupMessageRepository;
import horizon.example.demo.repository.GroupRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.GroupMessageService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GroupMessageServiceImpl implements GroupMessageService {

    private final GroupMessageRepository groupMessageRepository;
    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final TouristRepository touristRepository;

    @Override
    @Transactional
    public GroupMessageResponse send(Long groupId, SendGroupMessageRequest request) {
        if (!CurrentUser.id().equals(request.getTouristId())) {
            throw new AccessDeniedException("You can only send messages as yourself");
        }

        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found: " + groupId));
        Tourist sender = touristRepository.findById(request.getTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getTouristId()));

        boolean isMember = groupMemberRepository.findByGroupIdAndTouristId(groupId, sender.getId())
                .filter(member -> member.getStatus() == GroupMemberStatus.JOINED)
                .isPresent();
        if (!isMember) {
            throw new InvalidRequestException("Only joined group members can send messages");
        }

        GroupMessage saved = groupMessageRepository.save(GroupMessage.builder()
                .group(group)
                .sender(sender)
                .message(request.getMessage())
                .build());

        return toResponse(saved);
    }

    @Override
    public List<GroupMessageResponse> listByGroup(Long groupId) {
        if (!CurrentUser.isAdmin()) {
            boolean isMember = groupMemberRepository.findByGroupIdAndTouristId(groupId, CurrentUser.id())
                    .filter(member -> member.getStatus() == GroupMemberStatus.JOINED)
                    .isPresent();
            if (!isMember) {
                throw new AccessDeniedException("Only joined group members can read this chat");
            }
        }
        return groupMessageRepository.findByGroupIdOrderBySentAtAsc(groupId).stream()
                .map(this::toResponse)
                .toList();
    }

    private GroupMessageResponse toResponse(GroupMessage message) {
        return GroupMessageResponse.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getFullName())
                .message(message.getMessage())
                .sentAt(message.getSentAt())
                .build();
    }
}
