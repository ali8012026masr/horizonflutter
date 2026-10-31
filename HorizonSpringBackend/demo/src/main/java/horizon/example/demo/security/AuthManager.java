package horizon.example.demo.security;

import horizon.example.demo.service.JwtService;
import horizon.example.demo.util.AuthUtil;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

/**
 * Validates the bearer token presented on every non-public request and delegates
 * to {@link AuthProvider} to attach authorities.
 *
 * <p>Deviates from the ported reference by taking the access/refresh token pair
 * as plain method arguments instead of implementing Spring's
 * {@code AuthenticationManager} and pulling them off a thread-bound request via a
 * {@code RequestContextUtil} - login here never routes through this class at all
 * (it is a direct {@code AuthProvider.authenticate(...)} call from
 * {@code AuthServiceImpl}), so the URI-based branching and IP-blocking
 * bookkeeping in the original {@code AuthManager} have no counterpart here.
 */
@Component
@RequiredArgsConstructor
public class AuthManager {

    private final AuthProvider authProvider;
    private final JwtService jwtService;
    private final HorizonUserDetailsService userDetailsService;

    public Authentication authenticateBearer(String accessToken, String refreshToken) {
        if (accessToken == null || accessToken.isBlank()) {
            return null;
        }

        String username = AuthUtil.getUsernameFromAccessToken(accessToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        LocalDateTime tokensValidAfter = (userDetails instanceof HorizonUserDetails hud)
                ? hud.getUser().getTokensValidAfter()
                : null;

        BearerAuthenticationToken bearerAuth = jwtService.getBearerToken(accessToken, refreshToken,
                userDetails.getPassword(), tokensValidAfter);
        if (bearerAuth == null) {
            return null;
        }
        return authProvider.authenticate(bearerAuth);
    }
}
