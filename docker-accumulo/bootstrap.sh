#!/bin/bash

: ${ACCUMULO_HOME:=/usr/local/accumulo}


#printf 'default\naccumulo\naccumulo\n' | $ACCUMULO_HOME/bin/accumulo init
$ACCUMULO_HOME/bin/start-all.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

