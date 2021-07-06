package com.stdioh.meubitcoin.repository;

import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.Firestore;
import com.stdioh.meubitcoin.model.Fcm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Repository
public class FcmRepository {

    private static String COLLECTION_NAME = "fcm";
    @Autowired
    private Firestore _firestore;

         CollectionReference getColl(){
        return  _firestore.collection(COLLECTION_NAME);
    }

    public List<Fcm> getAll() throws ExecutionException, InterruptedException {
        return getColl().get().get().getDocuments().stream().map(snap -> new Fcm(snap)).collect(Collectors.toList());
    }
    public Fcm get(String id) throws ExecutionException, InterruptedException {
        return new Fcm(getColl().document(id).get().get());
    }
    public Fcm add(Fcm fcm) throws ExecutionException, InterruptedException {
        return new Fcm(getColl().add(fcm).get().get().get());
    }


}
