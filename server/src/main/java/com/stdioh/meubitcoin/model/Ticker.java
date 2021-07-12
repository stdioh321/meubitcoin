package com.stdioh.meubitcoin.model;

import com.fasterxml.jackson.annotation.*;
import lombok.Data;
import lombok.ToString;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.TimeZone;

@Data
@ToString
public class Ticker {
    private String high;
    private String low;
    private String vol;
    private String last;
    private String buy;
    private String sell;
    private String open;
    private Long date;
}