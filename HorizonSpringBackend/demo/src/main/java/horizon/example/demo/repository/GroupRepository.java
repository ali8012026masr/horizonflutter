package horizon.example.demo.repository;

import horizon.example.demo.entity.Group;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupRepository extends JpaRepository<Group, Long> {
    Optional<Group> findByJoinCode(String joinCode);
    List<Group> findByCreatedById(Long createdById);
}
