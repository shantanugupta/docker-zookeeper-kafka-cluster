# builder step used to download and configure spark environment
FROM openjdk:11.0.11-jre-slim-buster as builder

# Add Dependencies for PySpark
RUN apt-get update && apt-get install -y curl vim wget software-properties-common \
    ssh net-tools ca-certificates iputils-ping telnet gettext

#RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV ZOOKEEPER_VERSION=3.8.0 \
    KAFKA_VERSION=3.2.0 \
    ZOOKEEPER_HOME=/opt/zookeeper \
    KAFKA_HOME=/opt/kafka \
    PYTHONHASHSEED=1

# Download and uncompress zookeeper from the apache archive
RUN wget --no-verbose -O apache-zookeeper.tgz "https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" \
    && wget --no-verbose -O apache-kafka.tgz "https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz" \
    && mkdir -p ${ZOOKEEPER_HOME} \
    && mkdir -p ${KAFKA_HOME} \
    && mkdir -p ${ZOOKEEPER_HOME}/data \
    && tar -xf apache-zookeeper.tgz -C ${ZOOKEEPER_HOME} --strip-components=1 \    
    && tar -zxf apache-kafka.tgz -C ${KAFKA_HOME} --strip-components=1 \
    && rm apache-zookeeper.tgz \
    && rm apache-kafka.tgz