package horizon.example.demo.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "role")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public abstract class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    private String phone;

    private String address;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private UserStatus status = UserStatus.ACTIVE;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false, columnDefinition = "integer default 0")
    @Builder.Default
    private int failedLoginAttempts = 0;

    @Column(nullable = false, columnDefinition = "boolean default false")
    @Builder.Default
    private boolean accountLocked = false;

    private LocalDateTime lockedUntil;

    /** "Logout everywhere" watermark: tokens issued at or before this instant are refused. */
    private LocalDateTime tokensValidAfter;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public void incrementFailedLoginAttempts() {
        this.failedLoginAttempts++;
    }

    public void resetFailedLoginAttempts() {
        this.failedLoginAttempts = 0;
        this.accountLocked = false;
        this.lockedUntil = null;
    }

    public void lockAccount(long lockoutDurationMinutes) {
        this.accountLocked = true;
        this.lockedUntil = LocalDateTime.now().plusMinutes(lockoutDurationMinutes);
    }

    /**
     * True only while the lockout window is still open. A stale {@code true} in
     * {@code accountLocked} with an elapsed {@code lockedUntil} does not block
     * login - the window expiring is what unlocks the account.
     */
    public boolean isTemporarilyLocked() {
        return this.accountLocked && this.lockedUntil != null && LocalDateTime.now().isBefore(this.lockedUntil);
    }
}
