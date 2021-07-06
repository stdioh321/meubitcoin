package com.stdioh.meubitcoin.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.stdioh.meubitcoin.model.Note;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class FirebasePushNotificationService {

    @Autowired
    private FirebaseMessaging firebaseMessaging;

    private String sendNotification(Note note, String token, boolean isToken) throws FirebaseMessagingException {

        Notification notification = Notification
                .builder()
                .setTitle(note.getSubject())
                .setBody(note.getContent())
                .setImage(note.getImage())
                .build();

        var messageBuilder = Message
                .builder()
                .setNotification(notification)
                .putAllData(note.getData());

        if(isToken==true) messageBuilder.setToken(token);
        else    messageBuilder.setTopic(token);

        return firebaseMessaging.send(messageBuilder.build());
    }

    public String sendNotificationWithToken(Note note, String token) throws FirebaseMessagingException {
     return this.sendNotification(note,token,true);
    }
    public String sendNotificationWithTopic(Note note, String topic) throws FirebaseMessagingException {
     return this.sendNotification(note,topic,false);
    }


}
