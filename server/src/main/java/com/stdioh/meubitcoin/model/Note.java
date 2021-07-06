package com.stdioh.meubitcoin.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Map;

@Data
@AllArgsConstructor
public class Note {
    private String subject;
    private String content;
    private Map<String, String> data;
    private String image;
}