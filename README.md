# Setting up Zookeeper, Kafka cluster on Docker

### Objective: ###
This project helps setting-up zookeeper 3 node cluster along with kafka 3 node cluster. Idea is to do a hands-on in setting up zookeeper and kafka using docker and perform perform basic streaming operations.

For setting up kafka cluster, prerequisite is to setup zookeeper cluster which will act as a cluster manager for kafka.
To setup zookeeper, we need to configure environment variables.


### Zookeeper Cluster Setup

1. [zoo.cfg](conf/zoo.cfg) is a required configuration file for starting zookeeper node. This file should contain information about all the zookeeper nodes that should be the part of a cluster, data directory and few other parameters.
Zookeeper nodes information is explained below
    ```
    server.1=zookeeper-1:2788:3788
    server.2=zookeeper-2:2788:3788
    server.3=zookeeper-3:2788:3788
    ```

    ```server.1=zookeeper-1:2788:3788```
    This code follows the syntax `server.myid=host/ip:follower-port:leader-port`. You need to make sure myid file has been created in data directory with the same value being used at both the places.

2. [zookeeper_init](conf/zookeeper_init.sh) file is executed when the zookeeper container is starting. This file creates myid file under zookeeper data directory with it's value coming from environment variable. Here environment variable `$ZOOKEEPER_SERVER_ID` is being set in [docker-compose.yml](docker-compose.yml)
   
    ```
    echo $ZOOKEEPER_SERVER_ID > /opt/zookeeper/data/myid
    ```

Zookeeper node can be started using below code. This is going to create a myid file in data directory post which zookeeper node is being started in foreground to keep docker container up and running.
```
$zookeeper_home/conf/zookeeper_init.sh &&
          $zookeeper_home/bin/zkServer.sh start-foreground
```

Same step needs to be performed for all of the zookeeper nodes.

### Starting Kafka Cluster

1. [server.properties](conf/server.properties) file is modified to hold environment variables that are being set via [docker-compose.yml](docker-compose.yml). I explicity did set following three environment variables. These are the minimum no of variables that are required to be set to start kafka cluster.
    - `KAFKA_BROKER_ID` - This is a unique id given to each kafka node
    - `KAFKA_ADVERTISED_LISTENERS` - URL on which kafka should be listening for any requests
    - `KAFKA_ZOOKEEPER_CONNECT` - Cluster manager url of zookeeper
2. [kafka_init.sh](conf/kafka_init.sh) Replaces environment variable values in [server.properties](conf/server.properties) file and saves the output to `config/server.properties`. 

#### Starting kafka node
In order to start kafka node, we introduced a delay of 20 seconds so that all the zookeeper nodes have removed dead sessions before it's vailable for zookeeper nodes. Details can be found [here](https://stackoverflow.com/questions/39759071/error-while-starting-kafka-broker) regarding problem that might occur otherwise. 
Kafka cluster takes server.properties file as input for starting the node.
```
sleep 20 && $kafka_home/custom/kafka_init.sh &&
          $kafka_home/bin/kafka-server-start.sh
          $kafka_home/config/server.properties
```

## Some of the commands to test kafka cluster
Linux Shell
```
./kafka-topics.sh --bootstrap-server kafka-broker-1:9092 --create --replication-factor 1 --partitions 1 --topic simpletalk_topic
./kafka-topics.sh --bootstrap-server kafka-broker-1:9092 --describe
./kafka-console-producer.sh --bootstrap-server kafka-broker-1:9092 --topic simpletalk_topic
./kafka-console-consumer.sh --bootstrap-server kafka-broker-1:9092 --topic simpletalk_topic
```
Windows Shell
```
.\kafka-topics.bat --bootstrap-server localhost:19092 --create --replication-factor 1 --partitions 1 --topic simpletalk_topic
.\kafka-topics.bat --bootstrap-server localhost:19092 --describe
.\kafka-console-producer.bat --bootstrap-server localhost:19092 --topic simpletalk_topic
.\kafka-console-consumer.bat --bootstrap-server localhost:19092 --topic simpletalk_topic
```