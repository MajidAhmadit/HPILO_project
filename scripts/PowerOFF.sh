#!/bin/bash

List=$(cat $1)
BaseDIR="/root/hpilo"
LogFile=$BaseDIR/Output/${2:-output.$(basename $0).$(basename $1)}
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "NIC Details for $1" > $LogFile
echo "$Total Systems to check"
for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    Details=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/Set_Host_PowerOFF.xml|grep -i script)
    echo -e "$Host \t$Details" |tee -a $LogFile
done
