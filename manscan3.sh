#!/bin/sh

# EPG Scan durch Zappen durchführen
SVDRPSEND="svdrpsend 127.0.0.1 6419"
# Anzahl von Zeichen in der Zeile. Wenn < 50 zb: Kanalgruppen, Zeilen in Hilfsdatei auslagern
sed -n '/^.\{50\}/!p' /etc/vdr/channels.conf > /tmp/channels.tmp
DELAY=5
START_CHANNEL=1
# max. Zeilen in channel.conf - Kanalgruppen-Hilfsdatei
let "MAX_CHANNEL=`sed $= -n /etc/vdr/channels.conf` - `sed $= -n /tmp/channels.tmp`"

NEXT_EVENT=`$SVDRPSEND "NEXT rel" | grep ^250 | awk '{print $NF }'`
WAIT_TIME=`expr $MAX_CHANNEL \* \( $DELAY \* 2 \)`

if [ -z "$NEXT_EVENT" ]; then
NEXT_EVENT=86400 # sek.
echo Kein Timer gesetzt, setzte Dummywert von 86400.
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
