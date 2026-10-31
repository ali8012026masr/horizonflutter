package horizon.example.demo.controller;

import horizon.example.demo.dto.request.AttachGroupBookingRequest;
import horizon.example.demo.dto.request.CreateGroupRequest;
import horizon.example.demo.dto.request.JoinGroupRequest;
import horizon.example.demo.dto.request.SendGroupMessageRequest;
import horizon.example.demo.dto.response.GroupMemberResponse;
import horizon.example.demo.dto.response.GroupMessageResponse;
import horizon.example.demo.dto.response.GroupResponse;
import horizon.example.demo.service.GroupMessageService;
import horizon.example.demo.service.GroupService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
public class GroupController {

    private final GroupService groupService;
    private final GroupMessageService groupMessageService;

    @GetMapping("/{id}")
    public GroupResponse getById(@PathVariable Long id) {
        return groupService.getById(id);
    }

    @GetMapping("/tourist/{touristId}")
    public List<GroupResponse> listByTourist(@PathVariable Long touristId) {
        return groupService.listByTourist(touristId);
    }

    @PostMapping
    public ResponseEntity<GroupResponse> create(@Valid @RequestBody CreateGroupRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(groupService.create(request));
    }

    @PostMapping("/join")
    public GroupResponse join(@Valid @RequestBody JoinGroupRequest request) {
        return groupService.joinByCode(request);
    }

    @GetMapping("/{id}/members")
    public List<GroupMemberResponse> listMembers(@PathVariable Long id) {
        return groupService.listMembers(id);
    }

    @DeleteMapping("/{id}/members/{touristId}")
    public ResponseEntity<Void> removeMember(@PathVariable Long id, @PathVariable Long touristId) {
        groupService.removeMember(id, touristId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/booking")
    public GroupResponse attachBooking(@PathVariable Long id, @Valid @RequestBody AttachGroupBookingRequest request) {
        return groupService.attachBooking(id, request);
    }

    @PutMapping("/{id}/members/{touristId}/paid")
    public GroupMemberResponse markPaid(@PathVariable Long id, @PathVariable Long touristId) {
        return groupService.markPaid(id, touristId);
    }

    @GetMapping("/{id}/messages")
    public List<GroupMessageResponse> listMessages(@PathVariable Long id) {
        return groupMessageService.listByGroup(id);
    }

    @PostMapping("/{id}/messages")
    public ResponseEntity<GroupMessageResponse> sendMessage(
            @PathVariable Long id, @Valid @RequestBody SendGroupMessageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(groupMessageService.send(id, request));
    }
}
