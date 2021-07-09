package com.stdioh.meubitcoin.model;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.stdioh.meubitcoin.serializer.LocalDateTimeToTimestamp;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(name = "fcm")
@NoArgsConstructor
@ToString
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class Fcm {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private String id;

    @NotNull
    @NonNull
    private boolean above = true;

    @NonNull
    @NotNull
    private String coin;


    @JsonSerialize(using = LocalDateTimeToTimestamp.Serializer.class)
    @JsonDeserialize(using = LocalDateTimeToTimestamp.Deserializer.class)
    @CreationTimestamp
    private LocalDateTime date;

    @NotNull
    @NonNull
    @Column(name = "id_device")
    @JsonProperty("id_device")
    private String idDevice;

    @NotNull
    @NonNull
    private double price;


}

