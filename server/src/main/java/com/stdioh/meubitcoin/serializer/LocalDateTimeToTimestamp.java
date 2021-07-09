package com.stdioh.meubitcoin.serializer;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

public class LocalDateTimeToTimestamp {
    public static class Serializer extends JsonSerializer<LocalDateTime> {
        @Override
        public void serialize(LocalDateTime value, JsonGenerator gen, SerializerProvider serializers) throws IOException {
            //add your custom date parser
//        gen.writeNumber();
            gen.writeNumber(value.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
        }
    }

    public static class Deserializer extends JsonDeserializer<LocalDateTime> {

        @Override
        public LocalDateTime deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
            Long value;
            try {
                var temp = Long.parseLong(p.getValueAsString());
                value = p.getValueAsLong();
            } catch (Exception ex) {
                System.out.println(p.getValueAsString());
                value = LocalDateTime.parse(p.getValueAsString()).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
            }
            return LocalDateTime.ofInstant(Instant.ofEpochMilli(value),ZoneId.systemDefault());
        }
    }
}