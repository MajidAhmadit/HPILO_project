#!/bin/bash

List=$(cat $1)
LogFile=${2:-output.$(basename $0).$(basename $1)}
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "ILO FW Details for $1" > $LogFile
echo "$Total Systems to check"
for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    echo -n $Host >> $LogFile
    Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/getquickstats.xml |grep -A 3 "<INDEX_1>"|grep "FIRMWARE_VERSION" | tail -l)
    echo -e "\t$Details" >> $LogFile
done
cat $LogFile
