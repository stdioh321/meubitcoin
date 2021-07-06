package com.stdioh.meubitcoin.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.firebase.messaging.FirebaseMessaging;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.IOException;

@Configuration
public class FirebaseConfig {
    @PostConstruct
    public void initialization() {
        try {
            System.out.println("===============================================================");
            System.out.println("FirebaseConfig Initialization");
            System.out.println("===============================================================");
            var serviceAccount =getClass().getClassLoader().getResourceAsStream("serviceAccountKey.json");
//  new FileInputStream(ResourceUtils.getFile("classpath:serviceAccountKey.json"));
                    //  new ClassPathResource("serviceAccountKey.json").getInputStream()
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            FirebaseApp.initializeApp(options);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    @Bean
    public Firestore getFirestoreClient() {
        return FirestoreClient.getFirestore();
    }

    @Bean
    FirebaseMessaging getFirebaseMessaging(){
        return FirebaseMessaging.getInstance(FirebaseApp.getInstance());
    }
}
