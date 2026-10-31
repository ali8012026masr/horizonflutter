package horizon.example.demo.repository;

import horizon.example.demo.entity.GroupMessage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupMessageRepository extends JpaRepository<GroupMessage, Long> {
    List<GroupMessage> findByGroupIdOrderBySentAtAsc(Long groupId);
}
