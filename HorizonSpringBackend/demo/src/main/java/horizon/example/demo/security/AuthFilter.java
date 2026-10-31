package horizon.example.demo.security;

import horizon.example.demo.util.AuthUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Establishes the {@link SecurityContextHolder} authentication for every
 * non-public request by delegating to {@link AuthManager}.
 *
 * <p>When the access token was silently rotated (expired token + valid refresh
 * token), the new one is echoed back in the {@code x-access-token} response
 * header - that is how a client learns about the rotation without a separate
 * refresh call.
 */
@Component
@RequiredArgsConstructor
public class AuthFilter extends OncePerRequestFilter {

    /** Endpoints reachable with no token at all - registration/login, and read-only browsing before signup. */
    private static final List<RequestMatcher> PUBLIC_URLS = List.of(
            // Deliberately NOT a "/api/auth/**" wildcard - that would also skip
            // authentication for PUT /api/auth/change-password, which needs a
            // real logged-in user (CurrentUser.id() reads the SecurityContext
            // this filter populates).
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/register/tourist"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/register/provider"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/register/guide"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/login"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/forgot-password"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.POST, "/api/auth/reset-password"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/slots/search"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/slots/{id}"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/guide-availability/search"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/guide-availability/guide/{guideId}"),
            // Deliberately NOT a "/api/guides/**" wildcard - that would also expose
            // GET /api/guides/{id}/location (live GPS) with no auth at all.
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/guides"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/guides/{id}"),
            PathPatternRequestMatcher.pathPattern(HttpMethod.GET, "/api/ratings/**"));

    private final AuthManager authManager;
    private final AuthEntryPoint authEntryPoint;
    private volatile RequestMatcher publicUrls;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        RequestMatcher matcher = publicUrls;
        if (matcher == null) {
            matcher = new OrRequestMatcher(PUBLIC_URLS.toArray(new RequestMatcher[0]));
            publicUrls = matcher;
        }
        return matcher.matches(request);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authorizationHeader = request.getHeader("Authorization");
        String accessToken = (authorizationHeader != null && authorizationHeader.startsWith("Bearer "))
                ? authorizationHeader.substring("Bearer ".length())
                : null;
        String refreshToken = request.getHeader("x-refresh-token");

        Authentication auth;
        try {
            auth = authManager.authenticateBearer(accessToken, refreshToken);
            if (auth == null) {
                throw AuthUtil.getAuthenticationException("Missing or invalid Authorization header", null);
            }
        } catch (AuthenticationException e) {
            SecurityContextHolder.clearContext();
            authEntryPoint.commence(request, response, e);
            return;
        }

        SecurityContextHolder.getContext().setAuthentication(auth);

        String rotatedAccessToken = Objects.toString(auth.getCredentials(), "");
        if (!rotatedAccessToken.isBlank()) {
            response.setHeader("x-access-token", rotatedAccessToken);
        }

        filterChain.doFilter(request, response);
    }
}
