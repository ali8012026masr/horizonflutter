package horizon.example.demo.repository.spec;

import horizon.example.demo.dto.request.ServiceSlotSearchRequest;
import horizon.example.demo.entity.ServiceSlot;
import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;

public class ServiceSlotSpecifications {

    private ServiceSlotSpecifications() {
    }

    public static Specification<ServiceSlot> fromSearch(ServiceSlotSearchRequest request) {
        return (root, query, cb) -> {
            List<jakarta.persistence.criteria.Predicate> predicates = new ArrayList<>();

            if (request.getCategory() != null) {
                predicates.add(cb.equal(root.get("category"), request.getCategory()));
            }
            if (request.getOrigin() != null) {
                predicates.add(cb.equal(root.get("origin"), request.getOrigin()));
            }
            if (request.getDestination() != null) {
                predicates.add(cb.equal(root.get("destination"), request.getDestination()));
            }
            if (request.getLocationName() != null) {
                predicates.add(cb.equal(root.get("locationName"), request.getLocationName()));
            }
            if (request.getDateFrom() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("startDateTime"), request.getDateFrom()));
            }
            if (request.getDateTo() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("startDateTime"), request.getDateTo()));
            }
            if (request.getMinPrice() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("price"), request.getMinPrice()));
            }
            if (request.getMaxPrice() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("price"), request.getMaxPrice()));
            }

            return cb.and(predicates.toArray(new jakarta.persistence.criteria.Predicate[0]));
        };
    }
}
