FROM alpine:3.14 as base
ENV BASE_URL=https://archive.apache.org/dist/kafka
ENV LOG_DIR=/var/log
ENV KAFKA_VERSION=3.1.0
ENV SCALA_VERSION=2.13
ENV CONFIG_FILE=/opt/kafka/config/kraft/server.properties

RUN apk update \
  && apk add --no-cache bash curl jq openjdk8-jre \
  && curl ${BASE_URL}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -o /tmp/kafka.tgz \
  && tar xfz /tmp/kafka.tgz -C /opt \
  && rm /tmp/kafka.tgz \
  && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
  && sed -r -i "s@^#?log\.dirs=.*@log\.dirs=${LOG_DIR}@g" ${CONFIG_FILE}

COPY --chmod=754 ./docker-wrapper.sh /opt/kafka/.
ENTRYPOINT [ "/opt/kafka/docker-wrapper.sh" ]
CMD [ "init" ]

FROM base as node
CMD [ "start" ]
