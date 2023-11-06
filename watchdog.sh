#!/bin/bash

cd /root/

#if [ $SYSTEM_TYPE == "dev" ];
#then
#    cp -f ./.kube/config_dev ./.kube/config;
#fi;

#if [ $SYSTEM_TYPE == "prd-krc" ];
#then
#    cp -f ./.kube/config_prdkrc ./.kube/config;
#fi;

#if [ $SYSTEM_TYPE == "prd-krs" ];
#then
#    cp -f ./.kube/config_prdkrs ./.kube/config;
#fi;

#if [ $SYSTEM_TYPE == "stg-krc" ];
#then
#    cp -f ./.kube/config_stgkrc ./.kube/config;
#fi;

#if [ $SYSTEM_TYPE == "stg-krs" ];
#then
#    cp -f ./.kube/config_stgkrs ./.kube/config;
#fi;

./kafkacontrol.sh&

percnt=($ALLOWS);

PARAMCNT=$(tr -dc ';' <<< $PARAMINPUTS | wc -c);
PARAMS=$(echo $PARAMINPUTS | tr ";" "\n");
IFS=';';

while true;
do
    rm pods;
    kubectl get po -o wide | grep -o comm-[a-zA-Z0-9\-]* >> pods;

    while read line;
        do
        rm errdata;
        kubectl logs $line --since=1m >> errdata;
        read -ra field <<< $PARAMINPUTS
        for findval in "${field[@]}";
        do
            rm errdatafin;
            cat errdata | grep -o "$findval" >> errdatafin;
            errdatalen=$(grep -o "$findval" errdatafin | wc -l);
            if [ $errdatalen -ge $percnt ];
            then
                kubectl delete pod $line &
                echo "kubectl delete pod $line";
            fi;
            sleep 1s;
        done;
    done < pods;
    sleep 1s;
    echo "I am finding some keyword..."
done;