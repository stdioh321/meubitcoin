#!/bin/bash


gradle clean build;
java -jar $JAR_ARGS build/libs/server*.jar $JAVA_ARGS --server-port=$PORT