package horizon.example.demo.security;

import horizon.example.demo.entity.User;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/** Reads the authenticated {@link User} set by {@link AuthFilter} for the current request. */
public final class CurrentUser {

    private CurrentUser() {
    }

    public static User get() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Object principal = auth != null ? auth.getPrincipal() : null;
        if (!(principal instanceof HorizonUserDetails details)) {
            throw new AccessDeniedException("No authenticated user in this request");
        }
        return details.getUser();
    }

    public static Long id() {
        return get().getId();
    }

    public static boolean isAdmin() {
        return "ADMIN".equals(HorizonUserDetails.roleFor(get()));
    }
}
