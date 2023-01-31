FROM ubuntu:20.04

WORKDIR /data

ENV KAFKA_SCALA_VERSION=2.12
ENV KAFKA_VERSION=3.3.1

EXPOSE 30092
EXPOSE 9092
EXPOSE 9093

RUN apt-get update -y
RUN apt-get install openjdk-8-jdk -y
RUN apt-get install wget -y

RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN tar zxvf kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN ln -s kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION} kafka

# dynamic setting kafka properties in kraft
COPY start-kafka.sh /data
COPY server.properties /data

RUN rm -rf /data/kafka/config/kraft/server.properties

RUN cp /data/server.properties /data/kafka/config/kraft

RUN mkdir /data/kafka/kafka-logs

RUN chmod a+x /data/start-kafka.sh

ENTRYPOINT ["sh", "/data/start-kafka.sh"]