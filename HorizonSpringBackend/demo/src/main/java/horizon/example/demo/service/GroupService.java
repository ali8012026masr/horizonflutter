package horizon.example.demo.service;

import horizon.example.demo.dto.request.AttachGroupBookingRequest;
import horizon.example.demo.dto.request.CreateGroupRequest;
import horizon.example.demo.dto.request.JoinGroupRequest;
import horizon.example.demo.dto.response.GroupMemberResponse;
import horizon.example.demo.dto.response.GroupResponse;
import java.util.List;

public interface GroupService {
    GroupResponse getById(Long groupId);
    List<GroupResponse> listByTourist(Long touristId);
    GroupResponse create(CreateGroupRequest request);
    GroupResponse joinByCode(JoinGroupRequest request);
    List<GroupMemberResponse> listMembers(Long groupId);
    void removeMember(Long groupId, Long touristId);
    GroupResponse attachBooking(Long groupId, AttachGroupBookingRequest request);
    GroupMemberResponse markPaid(Long groupId, Long touristId);
}
