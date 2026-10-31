package horizon.example.demo.config;

import horizon.example.demo.security.AuthAccessDeniedHandler;
import horizon.example.demo.security.AuthEntryPoint;
import horizon.example.demo.security.AuthFilter;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AuthorizeHttpRequestsConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Stateless JWT security, replacing the {@code CorsConfig} WebMvcConfigurer
 * (Security's own CORS handling is now the single source of truth - having both
 * risks duplicate {@code Access-Control-Allow-Origin} headers).
 *
 * <p>Authorization rules are a plain hardcoded rule set rather than the ported
 * reference's {@code permissions.json}-driven scheme - there's exactly one app
 * here, not a multi-service permission matrix, so data-driven authorization
 * would be indirection with no payoff. Path prefixes not covered by an explicit
 * rule below fall through to {@code anyRequest().authenticated()}, i.e. any
 * logged-in role, not a specific one - fine-grained per-role/ownership checks
 * (e.g. "only this provider can edit this slot") still need to be added at the
 * service layer as a follow-up; this config only establishes the outer
 * authenticated/anonymous/admin-only boundary.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final AuthEntryPoint authEntryPoint;
    private final AuthAccessDeniedHandler accessDeniedHandler;
    private final AuthFilter authFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(csrf -> csrf.disable())
                .headers(headers -> headers.frameOptions(frameOptions -> frameOptions.disable()))
                .formLogin(formLogin -> formLogin.disable())
                .httpBasic(httpBasic -> httpBasic.disable())
                .anonymous(anonymous -> anonymous.disable())
                .authorizeHttpRequests(this::configureRequestAuthorization)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(authEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                .addFilterBefore(authFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    private CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:54200"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setExposedHeaders(List.of("x-access-token", "x-refresh-token"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    private void configureRequestAuthorization(
            AuthorizeHttpRequestsConfigurer<HttpSecurity>.AuthorizationManagerRequestMatcherRegistry auth) {
        auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/slots/search", "/api/slots/{id}").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/guide-availability/search",
                        "/api/guide-availability/guide/{guideId}").permitAll()
                .requestMatchers(HttpMethod.PUT, "/api/guides/*/location").hasAuthority("TOUR_GUIDE")
                .requestMatchers(HttpMethod.GET, "/api/guides/*/location").authenticated()
                .requestMatchers(HttpMethod.GET, "/api/guides", "/api/guides/{id}").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/ratings/**").permitAll()
                .requestMatchers("/api/ai/**").hasAuthority("TOURIST")
                .requestMatchers("/api/admin/**").hasAuthority("ADMIN")
                .anyRequest().authenticated();
    }
}
