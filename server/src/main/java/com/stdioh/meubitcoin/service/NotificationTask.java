package com.stdioh.meubitcoin.service;

import com.stdioh.meubitcoin.model.Note;
import com.stdioh.meubitcoin.repository.FcmRepository;
import com.stdioh.meubitcoin.repository.TickerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class NotificationTask {
    @Autowired
    private FirebasePushNotificationService firebasePushNotificationService;

    @Autowired
    private FcmRepository fcmRepository;

    @Autowired
    private TickerRepository tickerRepository;


    HashMap<String, LocalDateTime> sentMessages = new HashMap();
    final long secondsAfterLastMessage = 60;
    private static final Logger logger = LoggerFactory.getLogger(NotificationTask.class);

    @Scheduled(fixedRate = 5000)
    public void sendNotifications() {
        try {

            var fcmList = fcmRepository.getAll();
            var fcmGroup = fcmList.stream().collect(Collectors.groupingBy(f -> f.getCoin()));
            fcmGroup.forEach((coin, fcms) -> {
                try {

                    var currentTicker = tickerRepository.get(coin);
                    coin = coin.substring(3);
                    for (var fcm : fcms) {
                        if (fcm.isAbove() == true && Double.parseDouble(currentTicker.getBuy()) >= fcm.getPrice()) {

                            String titulo = String.format("A moeda %s subiu", coin);
                            String corpo = String.format("A %s está acima de R$ %s", coin, String.valueOf(fcm.getPrice()));
                            String image = "https://image.flaticon.com/icons/png/512/2097/2097160.png";
                            Note note = new Note(titulo, corpo, new HashMap<>(), image);
                            if (candSend(fcm.getIdDevice())){
                                firebasePushNotificationService.sendNotificationWithToken(note, fcm.getIdDevice());
                                sentMessages.put(fcm.getIdDevice(), LocalDateTime.now());
                            }


                        } else if (fcm.isAbove() == false && Double.parseDouble(currentTicker.getBuy()) < fcm.getPrice()) {
                            String titulo = String.format("A moeda %s desceu", coin);
                            String corpo = String.format("A %s está abaixo de R$ %s", coin, String.valueOf(fcm.getPrice()));
                            String image = "https://image.flaticon.com/icons/png/512/2097/2097160.png";
                            Note note = new Note(titulo, corpo, new HashMap<>(), image);
                            if (candSend(fcm.getIdDevice())){
                                firebasePushNotificationService.sendNotificationWithToken(note, fcm.getIdDevice());
                                sentMessages.put(fcm.getIdDevice(), LocalDateTime.now());
                            }
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            });

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private boolean candSend(String token) {
        if (sentMessages.containsKey(token)) {
            var lastTimeSent = sentMessages.get(token);
            return lastTimeSent.plusSeconds(secondsAfterLastMessage).isBefore(LocalDateTime.now());
        }
        return true;
    }

}
