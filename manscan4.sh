#!/bin/sh


### START - Anzahl der Kanäle in channels.conf ermitteln

# Zähle Zeilen mit einer Länge < 50, z.b.: Kanalgruppen
CHANNELS_CONF_COMMENT_LINES=`sed -n '/^.\{50\}/!p' /etc/vdr/channels.conf | wc -l`
echo "CHANNELS_CONF_COMMENT_LINES:" $CHANNELS_CONF_COMMENT_LINES

# Zähle alle Zeilen in Datei
CHANNELS_CONF_TOTAL_LINES=`cat /etc/vdr/channels.conf | wc -l`
echo "CHANNELS_CONF_TOTAL_LINES:" $CHANNELS_CONF_TOTAL_LINES

# Ziehe Kommentarzeilen von allen Zeilen ab um die Anzahl der Kanäle ohne Kommentarzeilen zu erhalten
CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS=`expr $CHANNELS_CONF_TOTAL_LINES \- $CHANNELS_CONF_COMMENT_LINES`
echo "CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS:" $CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS


### DONE - Anzahl der Kanäle in channels.conf ermitteln


# Umgeschaltet wird per SVDRPSEND, setze den Pfad zum binary (Voller Pfad ist wichtig damit das Script auch per cronjob lauffähig ist)
SVDRPSEND=/usr/local/bin/svdrpsend
echo "VAR_SVDRPSEND:" $SVDRPSEND



# Wir fragen den VDR wann die nächste Aufnahme ansteht
NEXT_EVENT=`$SVDRPSEND "NEXT rel" | grep ^250 | awk '{print $NF }'`
echo "NEXT_EVENT:" $NEXT_EVENT

DELAY=11
echo "DELAY:" $DELAY

WAIT_TIME=`expr $CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS \* \( $DELAY \* 2 \)`
echo WAIT_TIME: $WAIT_TIME


if [ $NEXT_EVENT -gt $WAIT_TIME ]; then

	# Die Schleife schaltet alle Kanäle von 1 - $CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS nach einander durch
	counter=1
	while [ $counter -le $CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS ]
	do
	  echo "VAR_counter": $counter of $CHANNELS_CONF_TOTAL_NUM_OF_CHANNELS
	  $SVDRPSEND "CHAN" $counter > /dev/null
	  sleep 1s
	  tail /var/log/syslog -n 5 | grep "switching to channel $counter"
	  sleep 10s
	  counter=`expr $counter + 1`
	done
else
	echo Nicht genug Zeit. Kein EPG-Scan.
fi
echo END OF SCRIPT
