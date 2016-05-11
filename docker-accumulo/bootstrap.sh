#!/bin/bash

: ${ACCUMULO_HOME:=/usr/local/accumulo}

#keep an up to date ip in the accumulo configuration
IP=$(ifconfig eth0 | grep -oP '\d+\.\d+\.\d+\.\d+' | head -n1)
IPCONFIGS="$ACCUMULO_HOME/conf/masters $ACCUMULO_HOME/conf/slaves"
for conf in $IPCONFIGS; do
	if [[ -z "$(grep $IP $conf)" ]]; then
		echo $IP >> $conf
	fi;
done;

printf 'accumulo\naccumulo\naccumulo\n' | $ACCUMULO_HOME/bin/accumulo init
$ACCUMULO_HOME/bin/start-all.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

