#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

#[ $LOG_DIR == "/var/log" ] && echo “true” || echo “false”
if [ -z "$1" ]; then
    echo "You must provide a command line argument"
else
    properties_file=/opt/kafka/config/kraft/server.properties
    kafka_addr=localhost:9093
    if [ $1 == "init" ]; then
        echo "Starting init!"
        echo "==> Log directory environment variable... ${LOG_DIR}"
        
        kafka_log_dir=$(sed -n "s/^log\.dirs=\(.*\)$/\1/p" /opt/kafka/config/kraft/server.properties)
        echo "==> Log directory in server.properties ... ${kafka_log_dir}"
        if [ $kafka_log_dir != $LOG_DIR ]; then
            echo "WARN: Log directories do not match!"
        fi
        if [ -z $kafka_log_dir ]; then
            echo "🚨 Log directory missing.";
        else
            echo "==> ✅ Log diretory verified on filesystem."
        fi
    elif [ $1 == "cluster" ]; then
    # #export KAFKA_CLUSTER_ID=$(./bin/kafka-storage.sh random-uuid)
    # #echo "==> Setting up Kafka storage...";
    # #export suuid=$(./bin/kafka-storage.sh random-uuid);
    # #/opt/kafka/bin/kafka-storage.sh format -t $suuid -c /opt/kafka/config/kraft/server.properties;
    # #echo "==> ✅ Kafka storage setup.";
    # echo "==> Starting Kafka server...";
    # /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties &
    # child=$!
    # echo "==> ✅ Kafka server started.";

    # wait "$child";

    else
        echo "I got ${1}"
    fi

    # echo "==> Applying environment variables...";
    # sed -r -i "s@^#?node\.id=.*@node\.id=${MY_ID}@g" $properties_file;
    # sed -r -i "s@^#?controller\.quorum\.voters=.*@controller\.quorum\.voters=${MY_ID}\@localhost:9093,${ALT1_ID}\@localhost:9093,${ALT2_ID}\@localhost:9093@g" $properties_file;
    # echo "==> ✅ Enivronment variables applied.";

fi
