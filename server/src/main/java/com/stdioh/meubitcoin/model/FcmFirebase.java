package com.stdioh.meubitcoin.model;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import java.util.HashMap;
import java.util.Map;


@Data
@RequiredArgsConstructor
public class FcmFirebase {
    @JsonIgnore
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private String id;
    @NonNull
    private boolean above;
    @NonNull
    private String coin;
    @NonNull
    private Timestamp date;
    @NonNull
    private String idDevice;
    @NonNull
    private double price;

    public FcmFirebase(DocumentSnapshot snap){
        this.id = snap.getId();
        this.above = (boolean) snap.get("above");
        this.coin = (String) snap.get("coin");
        this.date = (Timestamp) snap.get("date");
        this.idDevice = (String) snap.get("id_device");
        this.price = (double) snap.get("price");
    }
}
