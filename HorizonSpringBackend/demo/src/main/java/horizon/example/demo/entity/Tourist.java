package horizon.example.demo.entity;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@DiscriminatorValue("TOURIST")
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
public class Tourist extends User {

    @Column(nullable = false)
    private int loyaltyPoints;
}
