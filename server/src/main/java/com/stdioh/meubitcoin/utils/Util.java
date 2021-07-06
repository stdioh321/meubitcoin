package com.stdioh.meubitcoin.utils;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Singleton;

public class Util {
    private static Util instance;
    private Util(){};
    public static Util getInstance(){
        if(instance == null) instance = new Util();
        return instance;
    }
    public ObjectMapper objectMapper = new ObjectMapper();
}
