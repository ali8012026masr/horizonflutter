package horizon.example.demo.repository.spec;

import horizon.example.demo.dto.request.GuideAvailabilitySearchRequest;
import horizon.example.demo.entity.GuideAvailability;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;

public class GuideAvailabilitySpecifications {

    private GuideAvailabilitySpecifications() {
    }

    public static Specification<GuideAvailability> fromSearch(GuideAvailabilitySearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getDateFrom() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("date"), request.getDateFrom()));
            }
            if (request.getDateTo() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("date"), request.getDateTo()));
            }
            if (request.getLocation() != null) {
                predicates.add(cb.equal(root.get("location"), request.getLocation()));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
