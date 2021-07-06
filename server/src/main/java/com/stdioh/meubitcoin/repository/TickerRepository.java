package com.stdioh.meubitcoin.repository;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.stdioh.meubitcoin.model.Ticker;
import org.springframework.stereotype.Repository;
import org.springframework.web.client.RestTemplate;

import java.time.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

@Repository
public class TickerRepository {
    private final RestTemplate _restTemplate = new RestTemplate();
    private String _url = "https://cdn.mercadobitcoin.com.br/api/tickers?pairs=";

    public Ticker get(String pair){
        Map<String, ArrayList<LinkedHashMap>> res = this._restTemplate.getForObject(_url+pair, Map.class);
        var mapTicker = res.get("ticker").stream().findFirst().get();
        var mapper = new ObjectMapper();
        mapper = mapper.registerModule(new JavaTimeModule());
        var t = mapper.convertValue(mapTicker, Ticker.class);
        return t;
    }
}
