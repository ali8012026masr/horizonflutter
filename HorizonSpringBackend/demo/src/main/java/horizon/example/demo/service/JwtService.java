package horizon.example.demo.service;

import horizon.example.demo.security.BearerAuthenticationToken;
import horizon.example.demo.security.InvalidTokenInHeaderException;
import horizon.example.demo.security.SessionExpiredException;
import horizon.example.demo.util.AuthUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.crypto.SecretKey;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Component;

/**
 * Tokens are signed <b>per user, with that user's BCrypt password hash as the
 * HMAC secret</b>. Two consequences the rest of the flow depends on:
 *
 * <ul>
 * <li>Changing a password invalidates every token that user holds, with no
 * blacklist required.
 * <li>Verifying a token requires loading the user first, which is why
 * {@code AuthUtil.getUsernameFromAccessToken} reads the subject unverified.
 * </ul>
 */
@Slf4j
@Component
public class JwtService {

    @Value("${jwt.token.expiration.access:900000}")
    private long accessTokenExpiration;

    @Value("${jwt.token.expiration.refresh:604800000}")
    private long refreshTokenExpiration;

    public SecretKey generateKey(String secretKey) {
        return Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(String username, String secretKey) {
        return createToken(new HashMap<>(), username, accessTokenExpiration, secretKey);
    }

    public String generateRefreshToken(String username, String secretKey) {
        return createToken(new HashMap<>(), username, refreshTokenExpiration, secretKey);
    }

    public long getAccessTokenExpirationMillis() {
        return accessTokenExpiration;
    }

    private String createToken(Map<String, Object> claims, String subject, long expiration, String secretKey) {
        long now = System.currentTimeMillis();
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(new Date(now))
                .expiration(new Date(now + expiration))
                .signWith(generateKey(secretKey))
                .compact();
    }

    /**
     * Validates the presented access token and, when it has expired, silently
     * rotates it using the refresh token.
     *
     * @return a token whose credentials are the new access token if one was
     *         minted, or {@code null} credentials if the presented access token
     *         was still valid
     */
    public BearerAuthenticationToken getBearerToken(String accessToken, String refreshToken, String secretKey,
            LocalDateTime tokensValidAfter) throws AuthenticationException {
        try {
            if (accessToken == null || accessToken.isBlank()) {
                return null;
            }
            Claims claims;
            String issuedToken = accessToken;
            try {
                claims = extractAllClaims(accessToken, secretKey);
                issuedToken = null;
            } catch (SessionExpiredException e) {
                if (refreshToken == null || refreshToken.isBlank()) {
                    throw e;
                }
                claims = extractAllClaims(refreshToken, secretKey);
                issuedToken = generateAccessToken(claims.getSubject(), secretKey);
            }
            rejectIfRevoked(claims, tokensValidAfter);
            return new BearerAuthenticationToken(claims.getSubject(), issuedToken, true);
        } catch (SessionExpiredException e) {
            throw e;
        } catch (Exception e) {
            throw AuthUtil.getAuthenticationException(
                    "Bearer token validation failed: %s".formatted(e.getMessage()), e);
        }
    }

    /**
     * Enforces the "logout everywhere" watermark: a token whose {@code iat} is at
     * or before {@code tokensValidAfter} is refused even though its signature is
     * valid and it has not expired. The comparison is {@code <=}, not {@code <} -
     * a JWT {@code iat} has whole-second resolution while the watermark is
     * sub-second, so a strict {@code <} would let a token minted in the same
     * second as the revoke survive it.
     */
    private void rejectIfRevoked(Claims claims, LocalDateTime tokensValidAfter) {
        if (tokensValidAfter == null || claims == null) {
            return;
        }
        long validAfterEpochSecond = tokensValidAfter.atZone(ZoneId.systemDefault()).toEpochSecond();
        Date issuedAt = claims.getIssuedAt();
        if (issuedAt == null || issuedAt.toInstant().getEpochSecond() <= validAfterEpochSecond) {
            throw new SessionExpiredException("Session has been revoked. Please login again.");
        }
    }

    private Claims extractAllClaims(String token, String secretKey) {
        try {
            return Jwts.parser()
                    .verifyWith(generateKey(secretKey))
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            throw new SessionExpiredException("Session expired. Please login again.");
        } catch (Exception e) {
            throw new InvalidTokenInHeaderException("Invalid token in header", e);
        }
    }
}
