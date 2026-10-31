package horizon.example.demo.security;

import horizon.example.demo.entity.Admin;
import horizon.example.demo.entity.ServiceProvider;
import horizon.example.demo.entity.TourGuide;
import horizon.example.demo.entity.Tourist;
import horizon.example.demo.entity.User;
import horizon.example.demo.entity.UserStatus;
import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

/** Adapts {@link User} to Spring Security without polluting the entity with security concerns. */
public class HorizonUserDetails implements UserDetails {

    private final User user;

    public HorizonUserDetails(User user) {
        this.user = user;
    }

    public User getUser() {
        return user;
    }

    public static String roleFor(User user) {
        return switch (user) {
            case Admin ignored -> "ADMIN";
            case ServiceProvider ignored -> "SERVICE_PROVIDER";
            case TourGuide ignored -> "TOUR_GUIDE";
            case Tourist ignored -> "TOURIST";
            default -> "UNKNOWN";
        };
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(roleFor(user)));
    }

    @Override
    public String getPassword() {
        return user.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !user.isTemporarilyLocked();
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return user.getStatus() == UserStatus.ACTIVE;
    }
}
