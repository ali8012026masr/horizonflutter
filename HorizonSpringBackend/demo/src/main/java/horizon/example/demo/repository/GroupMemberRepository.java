package horizon.example.demo.repository;

import horizon.example.demo.entity.GroupMember;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    List<GroupMember> findByGroupId(Long groupId);
    List<GroupMember> findByTouristId(Long touristId);
    Optional<GroupMember> findByGroupIdAndTouristId(Long groupId, Long touristId);
}
