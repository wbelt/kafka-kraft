#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

#[ $LOG_DIR == "/var/log" ] && echo “true” || echo “false”
if [ -z "$1" ]; then
    echo "You must provide a command line argument.\n\nCurrent options are init or start."
else
    properties_file=/opt/kafka/config/kraft/server.properties
    kafka_addr=localhost:9093
    if [ $1 == "start" ]; then
        echo "Starting!"
        echo "==> Log directory environment variable... ${LOG_DIR}"
        
        if [ -z $properties_file ]; then
            echo "🚨 Properties file not found... $properties_file"
        else
            sed -r -i "s@^#?controller\.quorum\.voters=.*@controller\.quorum\.voters=1\@localhost:9093,2\@localhost:29093,3\@localhost:39093@g" $properties_file
            if [ $MY_ID == 2]; then
                sed -r -i "s@^#?listeners=.*@listeners=PLAINTEXT://:29092,CONTROLLER://:29093@g" $properties_file
                sed -r -i "s@^#?advertised.listeners=.*@advertised.listeners=PLAINTEXT://:29092@g" $properties_file
            elif [ $MY_ID == 3]; then
                sed -r -i "s@^#?listeners=.*@listeners=PLAINTEXT://:39092,CONTROLLER://:39093@g" $properties_file
                sed -r -i "s@^#?advertised.listeners=.*@advertised.listeners=PLAINTEXT://:39092@g" $properties_file
            else
                echo "🚨 Unknown MY_ID ($MY_ID), I only know how to deal with 1-3."
            fi
            echo "==> Applying environment variables..."
            sed -r -i "s@^#?node\.id=.*@node\.id=${MY_ID}@g" $properties_file
            kafka_log_dir=$(sed -n "s/^log\.dirs=\(.*\)$/\1/p" $properties_file)
            echo "==> Log directory in server.properties ... ${kafka_log_dir}"
            if [ $kafka_log_dir != $LOG_DIR ]; then
                echo "WARN: Log directories do not match!"
            fi
            if [ -z $kafka_log_dir ]; then
                echo "🚨 Log directory missing."
            else
                echo "==> ✅ Log diretory verified on filesystem."
                echo "==> Setting up Kafka storage for Cluser ID ${KAFKA_CLUSTER_ID}..."
                /opt/kafka/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c $properties_file
                echo "==> ✅ Kafka storage setup."
                echo "==> ✅ Enivronment variables applied.";
                echo "==> Starting Kafka server..."
                /opt/kafka/bin/kafka-server-start.sh $properties_file &
                child=$!
                echo "==> ✅ Kafka server started."
                wait "$child";
            fi
        fi
    else
        echo "Unexpected argument -- ${1}"
    fi
fi
