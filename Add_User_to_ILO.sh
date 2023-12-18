#!/bin/bash

List=$(cat $1)
    clear
echo $List
LogFile=${2:-output.$(basename $0).$(basename $1)}
DA=`date '+%D %H:%M'`
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "==============ILO Add user Details for $1 at $DA ===================" |tee -a  $LogFile
echo "$Total Systems to check"
steps=(Delete_User.xml admin.xml)


for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    echo -n $Host >> $LogFile
	for step in "${steps[@]}" ;do
	    Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/$step|grep "MESSAGE"|tail -n 1)
	    echo -e "Doing $step for $Host  $Details"  |tee -a $LogFile
	done
done
