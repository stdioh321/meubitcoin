package com.stdioh.meubitcoin.repository;

import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.Firestore;
import com.stdioh.meubitcoin.model.FcmFirebase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Repository
public class FcmFirebaseRepository {

    private static String COLLECTION_NAME = "fcm";
    @Autowired
    private Firestore _firestore;

         CollectionReference getColl(){
        return  _firestore.collection(COLLECTION_NAME);
    }

    public List<FcmFirebase> getAll() throws ExecutionException, InterruptedException {
        return getColl().get().get().getDocuments().stream().map(snap -> new FcmFirebase(snap)).collect(Collectors.toList());
    }
    public FcmFirebase get(String id) throws ExecutionException, InterruptedException {
        return new FcmFirebase(getColl().document(id).get().get());
    }
    public FcmFirebase add(FcmFirebase fcmFirebase) throws ExecutionException, InterruptedException {
        return new FcmFirebase(getColl().add(fcmFirebase).get().get().get());
    }


}
