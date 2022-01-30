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
            echo "==> Applying environment variables..."
            sed -r -i "s@^#?node\.id=.*@node\.id=${MY_ID}@g" $properties_file
            sed -r -i "s@^#?controller\.quorum\.voters=.*@controller\.quorum\.voters=${MY_ID}\@localhost:9093,${ALT1_ID}\@localhost:9093,${ALT2_ID}\@localhost:9093@g" $properties_file
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
