package horizon.example.demo.exception;

/** Thrown when the SMTP send fails (unconfigured, unreachable, rejected) - kept distinct from a raw MailException. */
public class EmailDeliveryException extends RuntimeException {
    public EmailDeliveryException(String message, Throwable cause) {
        super(message, cause);
    }
}
