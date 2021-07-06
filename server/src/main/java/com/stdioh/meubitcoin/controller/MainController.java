package com.stdioh.meubitcoin.controller;


import com.stdioh.meubitcoin.model.Note;
import com.stdioh.meubitcoin.repository.FcmRepository;
import com.stdioh.meubitcoin.service.FirebasePushNotificationService;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;

@RestController
@RequestMapping("/")
class MainController {
    @Autowired
    private FirebasePushNotificationService firebasePushNotificationService;

    @SneakyThrows
    @GetMapping
    ResponseEntity get() {
        return ResponseEntity.ok("ok");
    }
}