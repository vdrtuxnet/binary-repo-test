#!/bin/sh

# EPG Scan durch Zappen durchführen
SVDRPSEND="svdrpsend 127.0.0.1 6419"
DELAY=10
START_CHANNEL=1
MAX_CHANNEL=310

NEXT_EVENT=`$SVDRPSEND "NEXT rel" | grep ^250 | awk '{print $NF }'`
WAIT_TIME=`expr $MAX_CHANNEL \* \( $DELAY \* 2 \)`

if [ -z "$NEXT_EVENT" ]; then
NEXT_EVENT=86400 # sek. 
echo Keinen Timer gefunden, setzte Dummywert von 86400.
fi

echo Nächste Aufnahme in $NEXT_EVENT Sekunden, erforderliche Wartezeit $WAIT_TIME.
if [ $NEXT_EVENT -gt $WAIT_TIME ]; then
  echo Genug Zeit. Scanne EPG.
  CUR_CHANNEL=`$SVDRPSEND "CHAN $START_CHANNEL" | grep ^250 | cut -d' ' -f3-`
  TIMESTAMP=`date`
  echo $TIMESTAMP Geschaltet auf $CUR_CHANNEL
  sleep $DELAY
  for ZAP in `seq 2 $MAX_CHANNEL`; do
    CUR_CHANNEL=`$SVDRPSEND "CHAN +"  | grep ^250 | cut -d' ' -f3-`
    TIMESTAMP=`date`
    echo $TIMESTAMP Geschaltet auf $CUR_CHANNEL
    sleep $DELAY
  done
else
  echo Nicht genug Zeit. Kein EPG-Scan.
fi
