#!/bin/bash

List=$(cat $1)
BaseDIR="/root/hpilo"
LogFile=$BaseDIR/Output/${2:-output.$(basename $0).$(basename $1)}

Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "Health Summary for $1" > $LogFile
echo "$Total Systems to check"
for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
#    echo -n $Host >> $LogFile
    Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/gethealth.xml |grep -A 8 "<HEALTH_AT_A_GLANCE>"| grep -v HEALTH_AT_A_GLANCE|grep -v \"OK\"|grep -v "BATTERY STATUS= \"Not Installed\"")
    [ -n "$Details" ] && echo "$Host  $Details" >> $LogFile
done

echo
cat $LogFile
