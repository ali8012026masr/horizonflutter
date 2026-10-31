package horizon.example.demo.security;

import horizon.example.demo.exception.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AccountExpiredException;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.CredentialsExpiredException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.InsufficientAuthenticationException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;

/**
 * Renders authentication failures raised inside the security filter chain as the
 * same {@link ErrorResponse} shape the rest of the app's controllers use.
 *
 * <p>On a suspicious failure the stale token headers are blanked, prompting
 * clients that cache them to drop the credentials rather than keep retrying.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuthEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException authException) throws IOException {

        boolean isSuspicious = isSuspiciousException(authException);
        ErrorResponse errorResponse = toErrorResponse(authException);

        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        if (isSuspicious) {
            response.setHeader("x-access-token", "");
            response.setHeader("x-refresh-token", "");
            log.warn("Suspicious authentication attempt from IP: {}, User-Agent: {}, Error: {}",
                    request.getRemoteAddr(), request.getHeader("User-Agent"), authException.getMessage());
        }

        response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
    }

    private ErrorResponse toErrorResponse(AuthenticationException e) {
        Throwable cause = e.getCause() != null ? e.getCause() : e;

        String message;
        if (cause instanceof SessionExpiredException || e instanceof SessionExpiredException) {
            message = cause.getMessage();
        } else if (cause instanceof BadCredentialsException) {
            message = e.getMessage();
        } else if (cause instanceof DisabledException) {
            message = "Account is disabled";
        } else if (cause instanceof LockedException) {
            message = "Account is locked";
        } else if (cause instanceof AccountExpiredException) {
            message = "Account has expired";
        } else if (cause instanceof CredentialsExpiredException) {
            message = "Your password has expired. Please change your password.";
        } else {
            message = "You are not authorized to access this resource";
        }

        return ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.UNAUTHORIZED.value())
                .message(message)
                .build();
    }

    private boolean isSuspiciousException(AuthenticationException e) {
        return e instanceof InvalidTokenInHeaderException
                || e instanceof InsufficientAuthenticationException
                || e instanceof AuthenticationCredentialsNotFoundException
                || e instanceof BadCredentialsException;
    }
}
