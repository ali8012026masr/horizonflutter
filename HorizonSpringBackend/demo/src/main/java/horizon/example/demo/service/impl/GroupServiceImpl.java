package horizon.example.demo.service.impl;

import horizon.example.demo.dto.request.AttachGroupBookingRequest;
import horizon.example.demo.dto.request.CreateGroupRequest;
import horizon.example.demo.dto.request.JoinGroupRequest;
import horizon.example.demo.dto.response.GroupMemberResponse;
import horizon.example.demo.dto.response.GroupResponse;
import horizon.example.demo.entity.Booking;
import horizon.example.demo.entity.Group;
import horizon.example.demo.entity.GroupMember;
import horizon.example.demo.entity.GroupMemberStatus;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.exception.InvalidJoinCodeException;
import horizon.example.demo.exception.ResourceNotFoundException;
import horizon.example.demo.repository.BookingRepository;
import horizon.example.demo.repository.GroupMemberRepository;
import horizon.example.demo.repository.GroupRepository;
import horizon.example.demo.repository.TouristRepository;
import horizon.example.demo.security.CurrentUser;
import horizon.example.demo.service.GroupService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GroupServiceImpl implements GroupService {

    private static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final TouristRepository touristRepository;
    private final BookingRepository bookingRepository;

    @Override
    public GroupResponse getById(Long groupId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found: " + groupId));
        return toResponse(group);
    }

    @Override
    public List<GroupResponse> listByTourist(Long touristId) {
        if (!CurrentUser.isAdmin() && !CurrentUser.id().equals(touristId)) {
            throw new AccessDeniedException("You can only list your own groups");
        }
        return groupMemberRepository.findByTouristId(touristId).stream()
                .map(GroupMember::getGroup)
                .distinct()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public GroupResponse create(CreateGroupRequest request) {
        Tourist creator = touristRepository.findById(request.getCreatedByTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getCreatedByTouristId()));

        Group group = Group.builder()
                .groupName(request.getGroupName())
                .createdBy(creator)
                .joinCode(generateJoinCode())
                .build();
        groupRepository.save(group);

        GroupMember creatorMembership = GroupMember.builder()
                .group(group)
                .tourist(creator)
                .status(GroupMemberStatus.JOINED)
                .joinedAt(LocalDateTime.now())
                .build();
        groupMemberRepository.save(creatorMembership);

        return toResponse(group);
    }

    @Override
    @Transactional
    public GroupResponse joinByCode(JoinGroupRequest request) {
        Group group = groupRepository.findByJoinCode(request.getJoinCode())
                .orElseThrow(() -> new InvalidJoinCodeException("Invalid join code: " + request.getJoinCode()));
        Tourist tourist = touristRepository.findById(request.getTouristId())
                .orElseThrow(() -> new ResourceNotFoundException("Tourist not found: " + request.getTouristId()));

        groupMemberRepository.findByGroupIdAndTouristId(group.getId(), tourist.getId())
                .ifPresentOrElse(
                        existing -> {
                            existing.setStatus(GroupMemberStatus.JOINED);
                            existing.setJoinedAt(LocalDateTime.now());
                        },
                        () -> groupMemberRepository.save(GroupMember.builder()
                                .group(group)
                                .tourist(tourist)
                                .status(GroupMemberStatus.JOINED)
                                .joinedAt(LocalDateTime.now())
                                .build())
                );

        recalculateSplit(group);
        return toResponse(group);
    }

    @Override
    public List<GroupMemberResponse> listMembers(Long groupId) {
        requireGroupMembership(groupId);
        return groupMemberRepository.findByGroupId(groupId).stream().map(this::toMemberResponse).toList();
    }

    /**
     * Only a joined member of this group (or an admin) may read its details/roster -
     * otherwise any authenticated tourist could enumerate another group's trip info
     * by guessing/incrementing its id.
     */
    private void requireGroupMembership(Long groupId) {
        if (CurrentUser.isAdmin()) {
            return;
        }
        Long currentUserId = CurrentUser.id();
        boolean isMember = groupMemberRepository.findByGroupIdAndTouristId(groupId, currentUserId)
                .filter(member -> member.getStatus() == GroupMemberStatus.JOINED)
                .isPresent();
        if (!isMember) {
            throw new AccessDeniedException("Only joined members of this group can view its details");
        }
    }

    @Override
    @Transactional
    public void removeMember(Long groupId, Long touristId) {
        requireGroupMembership(groupId);
        GroupMember member = groupMemberRepository.findByGroupIdAndTouristId(groupId, touristId)
                .orElseThrow(() -> new ResourceNotFoundException("Group member not found"));
        Group group = member.getGroup();
        groupMemberRepository.delete(member);
        recalculateSplit(group);
    }

    @Override
    @Transactional
    public GroupResponse attachBooking(Long groupId, AttachGroupBookingRequest request) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group not found: " + groupId));
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + request.getBookingId()));

        group.setBooking(booking);
        recalculateSplit(group);
        return toResponse(group);
    }

    @Override
    @Transactional
    public GroupMemberResponse markPaid(Long groupId, Long touristId) {
        requireGroupMembership(groupId);
        GroupMember member = groupMemberRepository.findByGroupIdAndTouristId(groupId, touristId)
                .orElseThrow(() -> new ResourceNotFoundException("Group member not found"));
        member.setPaid(true);
        return toMemberResponse(member);
    }

    private void recalculateSplit(Group group) {
        if (group.getBooking() == null) {
            return;
        }
        List<GroupMember> joinedMembers = groupMemberRepository.findByGroupId(group.getId()).stream()
                .filter(member -> member.getStatus() == GroupMemberStatus.JOINED)
                .toList();
        if (joinedMembers.isEmpty()) {
            return;
        }
        BigDecimal share = group.getBooking().getTotalAmount()
                .divide(new BigDecimal(joinedMembers.size()), 2, RoundingMode.HALF_UP);
        joinedMembers.forEach(member -> member.setAmountOwed(share));
    }

    private String generateJoinCode() {
        String code;
        do {
            StringBuilder sb = new StringBuilder(6);
            for (int i = 0; i < 6; i++) {
                sb.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
            }
            code = sb.toString();
        } while (groupRepository.findByJoinCode(code).isPresent());
        return code;
    }

    private GroupResponse toResponse(Group group) {
        return GroupResponse.builder()
                .id(group.getId())
                .groupName(group.getGroupName())
                .createdByTouristId(group.getCreatedBy().getId())
                .joinCode(group.getJoinCode())
                .bookingId(group.getBooking() != null ? group.getBooking().getId() : null)
                .createdAt(group.getCreatedAt())
                .members(listMembers(group.getId()))
                .build();
    }

    private GroupMemberResponse toMemberResponse(GroupMember member) {
        return GroupMemberResponse.builder()
                .id(member.getId())
                .touristId(member.getTourist().getId())
                .touristName(member.getTourist().getFullName())
                .status(member.getStatus())
                .joinedAt(member.getJoinedAt())
                .amountOwed(member.getAmountOwed())
                .paid(member.isPaid())
                .build();
    }
}
