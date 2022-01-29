FROM alpine:3.14
ENV BASE_URL=https://archive.apache.org/dist/kafka
ENV KAFKA_VERSION=3.1.0
ENV SCALA_VERSION=2.13

RUN apk update \
  && apk add --no-cache bash curl jq

ADD ${BASE_URL}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /opt

RUN ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
  && apk add --no-cache bash openjdk8-jre

CMD [ "/opt/kafka/bin/kafka-server-start.sh" ]
