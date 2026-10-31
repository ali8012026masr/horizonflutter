package horizon.example.demo.service.impl;

import horizon.example.demo.exception.EmailDeliveryException;
import horizon.example.demo.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Override
    public void sendPasswordResetCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("Horizon password reset code");
        message.setText("Your password reset code is: " + code
                + "\n\nThis code expires in 15 minutes. If you didn't request this, ignore this email.");
        try {
            mailSender.send(message);
        } catch (MailException e) {
            throw new EmailDeliveryException("Unable to send email right now, try again later.", e);
        }
    }
}
