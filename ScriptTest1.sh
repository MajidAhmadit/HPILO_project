#!/bin/bash

List=$(cat $1)
clear
LogFile=${2:-output.$(basename $0).$(basename $1)}
Count=0
Total=$(wc -l $1|awk '{print $1}')
DA=`date '+%D %H:%M'`
echo "=====================New Execution of Script at $DA =================">> $LogFile
echo "ILO FW Details for $Total in $1 file " >> $LogFile
echo "$Total Systems to check"



for Host in $List; do
#    ((Count++))
#    echo -n .
#   (( Count % 10 )) || echo " $Count of $Total"
    
	nam=`echo $Host|awk -F "," '{print $1}'`
	ser=`echo $Host|awk -F "," '{print $2}'`

	SERIALL=$(perl locfg.pl -s 10.190.97.100 -f  scripts/Get_Host_Data_i82.xml |grep  "Serial Number"|tail -n 1|cut  -f3 -d=|cut -c2-11)
	if [ $SERIALL == $ser ]
	then 
	sed -s /Server/$nam/ Server_Set_Name.xml
	perl locfg.pl -s 10.190.97.100 -f  scripts/Server_Set_Name.xml 


done
