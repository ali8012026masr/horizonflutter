package horizon.example.demo.service;

import horizon.example.demo.dto.request.SendGroupMessageRequest;
import horizon.example.demo.dto.response.GroupMessageResponse;
import java.util.List;

public interface GroupMessageService {
    GroupMessageResponse send(Long groupId, SendGroupMessageRequest request);
    List<GroupMessageResponse> listByGroup(Long groupId);
}
