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
//    private String _url = "https://cdn.mercadobitcoin.com.br/api/tickers?pairs=";
    private String _url = "https://www.mercadobitcoin.net/api/%s/ticker/";

    public Ticker get(String coin){
        Map<String, LinkedHashMap> res = this._restTemplate.getForObject(String.format(_url, coin) , Map.class);
        var mapTicker = res.get("ticker");
        var mapper = new ObjectMapper();
        var t = mapper.convertValue(mapTicker, Ticker.class);
        return t;
    }
}
