package com.stdioh.meubitcoin.model;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import lombok.*;

import java.util.HashMap;
import java.util.Map;


@Data
@RequiredArgsConstructor
public class Fcm {
    @JsonIgnore
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

    public Fcm(DocumentSnapshot snap){
        this.id = snap.getId();
        this.above = (boolean) snap.get("above");
        this.coin = (String) snap.get("coin");
        this.date = (Timestamp) snap.get("date");
        this.idDevice = (String) snap.get("id_device");
        this.price = (double) snap.get("price");
    }
}
