package horizon.example.demo.service;

public interface EmailService {
    void sendPasswordResetCode(String toEmail, String code);
}
