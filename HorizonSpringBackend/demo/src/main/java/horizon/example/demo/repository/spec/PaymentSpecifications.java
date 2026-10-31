package horizon.example.demo.repository.spec;

import horizon.example.demo.dto.request.PaymentSearchRequest;
import horizon.example.demo.entity.Payment;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;

public class PaymentSpecifications {

    private PaymentSpecifications() {
    }

    public static Specification<Payment> fromSearch(PaymentSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getDateFrom() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("transactionDate"), request.getDateFrom()));
            }
            if (request.getDateTo() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("transactionDate"), request.getDateTo()));
            }
            if (request.getStatus() != null) {
                predicates.add(cb.equal(root.get("status"), request.getStatus()));
            }
            if (request.getMethod() != null) {
                predicates.add(cb.equal(root.get("method"), request.getMethod()));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
