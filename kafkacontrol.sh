#!/bin/bash

KAFKASERVIP='-1'

if [ $SYSTEM_TYPE == "dev" ];
then
    KAFKASERVIP='-1'
fi;

if [ $SYSTEM_TYPE == "prd-krc" ];
then
    KAFKASERVIP='81.80.16.103:9094'
fi;

if [ $SYSTEM_TYPE == "prd-krs" ];
then
    KAFKASERVIP='81.180.16.102:9094'
fi;

if [ $SYSTEM_TYPE == "stg-krc" ];
then
    KAFKASERVIP='81.79.14.112:9094'
fi;

if [ $SYSTEM_TYPE == "stg-krs" ];
then
    KAFKASERVIP='10.0.242.202:9094'
fi;

if [ $KAFKASERVIP == '-1' ]
then
    echo 'No Supporting Env';
    exit 0;
fi;

limitcnt=($SYSTEM_LIMIT);

while true;
do
    echo "tracking start"
    rm kafkagroupsa;
    rm kafkagroups;
    kubectl exec -ti my-cluster-zookeeper-0 -n kafka -- bin/kafka-consumer-groups.sh --bootstrap-server $KAFKASERVIP --list  >> kafkagroupsa;
    sed 's/\r$//' kafkagroupsa > kafkagroups

    while read -u 9 line
        do
	echo "$line checking...."
        rm lagdata
	rm lagdata1
	sum=0
        kubectl exec -i my-cluster-zookeeper-0 -n kafka -- bin/kafka-consumer-groups.sh --bootstrap-server $KAFKASERVIP --describe --group $line >> lagdata1
	cat lagdata1 | grep CommSvr | awk '{printf $6"\n"}' >> lagdata
        while read groupval
            do
	    sum=$((sum+groupval))
        done < lagdata
	lastval=$((sum));

        if [ $lastval -ge $limitcnt ]
        then
            echo '$line is over, killed'
            kubectl exec -i my-cluster-zookeeper-0 -n kafka -- bin/kafka-consumer-groups.sh --bootstrap-server $KAFKASERVIP --delete --group $line;
        fi;
	echo "do Something with $line, $lastval"
    done 9< kafkagroups

    echo "deleting lags...."
    sleep 3600s;
done;