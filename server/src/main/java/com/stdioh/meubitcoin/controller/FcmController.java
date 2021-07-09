package com.stdioh.meubitcoin.controller;

import com.stdioh.meubitcoin.model.Fcm;
import com.stdioh.meubitcoin.repository.FcmRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/fcm")
public class FcmController {
    @Autowired
    private FcmRepository fcmRepository;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity getAll(@RequestParam(required = false) String idDevice, @RequestParam(required = false) String coin) {
        if (idDevice != null && coin != null)
            return ResponseEntity.ok(fcmRepository.findByIdDeviceAndCoinIgnoreCase(idDevice, coin));
        return ResponseEntity.ok(fcmRepository.findAll());
    }

    @PostMapping
    ResponseEntity post(@Valid @RequestBody Fcm fcm) {
        System.out.println(fcm);
        return ResponseEntity.ok(fcmRepository.save(fcm));
    }

    @DeleteMapping("/{id}")
    ResponseEntity delete(@PathVariable("id") String id) {
        var fcm = fcmRepository.findById(id);
        if(fcm.isEmpty()) return ResponseEntity.notFound().build();
        fcmRepository.deleteById(id);
        return ResponseEntity.ok(fcm.get());
    }
}
