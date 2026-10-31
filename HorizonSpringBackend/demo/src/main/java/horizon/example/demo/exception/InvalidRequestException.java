package horizon.example.demo.exception;

/** Service-layer business-rule violations not covered by bean validation (e.g. category-specific field rules). */
public class InvalidRequestException extends RuntimeException {
    public InvalidRequestException(String message) {
        super(message);
    }
}
