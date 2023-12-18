#!/bin/bash

List=$(cat $1)
LogFile=${2:-output.$(basename $0).$(basename $1)}
Count554=0
Count530=0
Count534=0
CountUnknown=0
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "NIC Details for $1" > $LogFile
echo "$Total Systems to check"
for Host in $List
 do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
	Details=$(perl locfg.pl -s $Host-sc.ott.ciena.com -f scripts/Get_Host_Data.xml|grep -A 1 "FIELD NAME=\"Port\" VALUE=\"1\""|tail -n 1|sed -e 's/^.*=\"//' -e 's/\"\/>$//'|sed 's/-/:/g')
    echo -e "$Host \t$Details" |tee -a $LogFile
done
