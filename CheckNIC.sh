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
for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
#    echo -n $Host >> $LogFile
###locfg v5.40    #Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/getnic.xml |grep "PORT_DESCRIPTION VALUE" |tail -1| sed '
#locfg v6
    Details=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f scripts/getnic.xml |grep "PORT_DESCRIPTION VALUE" |tail -1| sed '
s/^.*= // 
s/\/>$//')
    echo -e "$Host \t$Details" |tee -a $LogFile
    case "$Details" in
	*554FLB*)
	    ((Count554++)) ;;
	*534FLB*) 
	    ((Count534++)) ;;
	*530FLB*) 
	    ((Count530++)) ;;
	*536FLB*) 
	    ((Count536++)) ;;
	*)
	    ((CountUnknown++)) ;;
    esac
done

echo
echo "Number of 530FLBs:  $Count530"
echo "Number of 534FLBs:  $Count534"
echo "Number of 536FLBs:  $Count536"
echo "Number of 554FLBs:  $Count554"
echo "Number of Unknowns:  $CountUnknown"
