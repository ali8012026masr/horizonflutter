package horizon.example.demo.security;

import horizon.example.demo.entity.User;
import horizon.example.demo.repository.UserRepository;
import horizon.example.demo.service.JwtService;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Verifies credentials and owns per-account lockout.
 *
 * <p>Handles two token shapes: a {@link UsernamePasswordAuthenticationToken}
 * (login - password is checked and an access token is minted into the credentials
 * slot) and a {@link BearerAuthenticationToken} (already-validated JWT - the
 * credentials pass through untouched).
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuthProvider implements AuthenticationProvider {

    private final HorizonUserDetailsService userDetailsService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Value("${security.account-lockout.max-attempts:5}")
    private int maxFailedAttempts;

    @Value("${security.account-lockout.duration-minutes:30}")
    private long lockoutDurationMinutes;

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String username = Objects.toString(authentication.getPrincipal(), "");
        String password = Objects.toString(authentication.getCredentials(), "");

        UserDetails userDetails;
        try {
            userDetails = userDetailsService.loadUserByUsername(username);
        } catch (UsernameNotFoundException e) {
            // Deliberately indistinguishable from a wrong password, to avoid enumeration.
            throw new BadCredentialsException("Invalid email or password");
        }

        if (!userDetails.isEnabled()) {
            throw new DisabledException("Account is disabled");
        }

        if (userDetails instanceof HorizonUserDetails hud) {
            User user = hud.getUser();
            if (user.isTemporarilyLocked()) {
                log.warn("Attempt to login to locked account: {}", username);
                throw new LockedException("Account is temporarily locked due to too many failed login attempts. "
                        + "Please try again later.");
            }

            if (authentication instanceof UsernamePasswordAuthenticationToken) {
                if (!passwordEncoder.matches(password, userDetails.getPassword())) {
                    handleFailedLogin(user);
                    throw new BadCredentialsException("Invalid email or password");
                }

                handleSuccessfulLogin(user);
                password = jwtService.generateAccessToken(username, userDetails.getPassword());
            }
        }

        return new UsernamePasswordAuthenticationToken(userDetails, password, userDetails.getAuthorities());
    }

    private void handleFailedLogin(User user) {
        user.incrementFailedLoginAttempts();
        if (user.getFailedLoginAttempts() >= maxFailedAttempts) {
            user.lockAccount(lockoutDurationMinutes);
            log.warn("Account locked for user: {} after {} failed attempts",
                    user.getEmail(), user.getFailedLoginAttempts());
        }
        userRepository.save(user);
    }

    private void handleSuccessfulLogin(User user) {
        if (user.isAccountLocked() || user.getFailedLoginAttempts() > 0) {
            user.resetFailedLoginAttempts();
            userRepository.save(user);
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.equals(authentication)
                || BearerAuthenticationToken.class.equals(authentication);
    }
}
