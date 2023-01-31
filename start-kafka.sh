#!/bin/sh

# for debug
set -x

PROCESS_ROLE="broker"
CONTROLLER_LISTENER_NAME="PLAINTEXT"
NODE_ID="${HOSTNAME##*-}"
POD_DOMAIN="kafka-$NODE_ID.kafka-head.default.svc.cluster.local"
LISTENERS="INTERNAL://:9092,EXTERNAL://${POD_DOMAIN}:3009${NODE_ID},CONTROLLER://:9093"
ADVERTISED_LISTENERS="INTERNAL://${POD_DOMAIN}:9092,EXTERNAL://${NODE_IP}:3009${NODE_ID}"

# controller node setting
if [ "${NODE_ID}" -lt "${VOTERS}" ]
then
  PROCESS_ROLE="broker,controller"
  CONTROLLER_LISTENER_NAME="CONTROLLER"
fi

CONTROLLER_QUORUM_VOTERS=""
for i in $(seq 0 $(($VOTERS - 1))); do
   CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.kafka-head.default.svc.cluster.local:9093,"
done
CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS%?}

# replace server.properties
sed -e "s+^node.id=.*+node.id=$NODE_ID+" \
-e "s+^process.roles=.*+process.roles=$PROCESS_ROLE+" \
-e "s+^controller.listener.names=.*+controller.listener.names=$CONTROLLER_LISTENER_NAME+" \
-e "s+^controller.quorum.voters=.*+controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS+" \
-e "s+^listeners=.*+listeners=$LISTENERS+" \
-e "s+^advertised.listeners=.*+advertised.listeners=$ADVERTISED_LISTENERS+" \
/data/kafka/config/kraft/server.properties > server.properties.updated \
&& mv server.properties.updated /data/kafka/config/kraft/server.properties

/data/kafka/bin/kafka-storage.sh format \
                   --config /data/kafka/config/kraft/server.properties \
                   --cluster-id "VZEXNSTvTkKMm-xE-ZvMYw"

/data/kafka/bin/kafka-server-start.sh /data/kafka/config/kraft/server.properties