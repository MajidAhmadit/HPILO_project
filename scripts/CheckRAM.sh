#!/bin/bash

List=$(cat $1)
BaseDIR="/root/hpilo"
LogFile=$BaseDIR/Output/${2:-output.$(basename $0).$(basename $1)}
Count554=0
Count530=0
Count534=0
CountUnknown=0
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "NIC Details for $1" > $LogFile
echo "$Total Systems to check"
for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    Details=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/Get_Host_Data.xml |grep Size|grep -v "not installed"|sed -e 's/.*=\"//' -e 's/\MB"\/>$//'|awk '{add+=$1/1024} END{ print add}')
    echo -e "$Host RAM SIZE is \t$Details  GB" |tee -a $LogFile
done

