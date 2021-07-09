package com.stdioh.meubitcoin.service;

import com.google.firebase.messaging.FirebaseMessagingException;
import com.stdioh.meubitcoin.model.Note;
import com.stdioh.meubitcoin.repository.FcmRepository;
import com.stdioh.meubitcoin.repository.TickerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class NotificationTask {
    @Autowired
    private FirebasePushNotificationService firebasePushNotificationService;

    @Autowired
    private FcmRepository fcmRepository;

    @Autowired
    private TickerRepository tickerRepository;

    @Value("${url.server}")
    private String urlServer;

    private RestTemplate restTemplate = new RestTemplate();

    HashMap<Map<String, String>, LocalDateTime> sentMessages = new HashMap();
    final long secondsAfterLastMessage = 300;
    private static final Logger logger = LoggerFactory.getLogger(NotificationTask.class);

    @Scheduled(fixedRate = 5000)
    public void keepHerokuAlive() {
        try {
            System.out.println(String.format("%s - %s", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")), urlServer));
            var ok = restTemplate.getForObject(urlServer, String.class);

        } catch (Exception ex) {

        }
    }

    @Scheduled(fixedRate = 5000)
    public void sendNotifications() {

        try {

            var fcmList = fcmRepository.findAll();
            var fcmGroup = fcmList.stream().collect(Collectors.groupingBy(f -> f.getCoin()));
            fcmGroup.forEach((coin, fcms) -> {
                try {

                    var currentTicker = tickerRepository.get(coin);
                    coin = coin.substring(3);
                    for (var fcm : fcms) {
                        try {

                            Map currMap = new HashMap() {{
                                put("idDevice", fcm.getIdDevice());
                                put("coin", fcm.getCoin());
                            }};

                            if (!canSend(currMap)) continue;

                            if (fcm.isAbove() == true && Double.parseDouble(currentTicker.getBuy()) >= fcm.getPrice()) {


                                System.out.println(String.format("Acima: %f, Token %s", fcm.getPrice(), fcm.getIdDevice()));
                                String titulo = String.format("A moeda %s subiu para R$ %s", coin, currentTicker.getBuy());
                                String corpo = String.format("A %s está acima de R$ %f", coin, fcm.getPrice());
                                String image = "https://image.flaticon.com/icons/png/512/2097/2097160.png";
                                Note note = new Note(titulo, corpo, new HashMap<>(), image);
                                firebasePushNotificationService.sendNotificationWithToken(note, fcm.getIdDevice());
                                sentMessages.put(currMap, LocalDateTime.now());


                            } else if (fcm.isAbove() == false && Double.parseDouble(currentTicker.getBuy()) < fcm.getPrice()) {


                                System.out.println(String.format("Abaixo: %f, Token %s", fcm.getPrice(), fcm.getIdDevice()));
                                String titulo = String.format("A moeda %s desceu para R$ %s", coin, currentTicker.getBuy());
                                String corpo = String.format("A %s está abaixo de R$ %f", coin, fcm.getPrice());
                                String image = "https://image.flaticon.com/icons/png/512/2097/2097160.png";
                                Note note = new Note(titulo, corpo, new HashMap<>(), image);
                                firebasePushNotificationService.sendNotificationWithToken(note, fcm.getIdDevice());
                                sentMessages.put(currMap, LocalDateTime.now());

                            }
                        }catch (FirebaseMessagingException fbmEx){
                            if(fbmEx.getMessagingErrorCode().name() == "UNREGISTERED") fcmRepository.delete(fcm);
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

    private boolean canSend(Map<String, String> fcm) {
        if (sentMessages.containsKey(fcm)) {
            var lastTimeSent = sentMessages.get(fcm);
            return lastTimeSent.plusSeconds(secondsAfterLastMessage).isBefore(LocalDateTime.now());
        }
        return true;
    }

}
