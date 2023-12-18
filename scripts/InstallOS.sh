#!/bin/bash

###########################################################################
##
## Install Centos6.10 with minimum Packages.  
## Version 1.0
##
##
## To use this program, you have to pass  a file   
##
## PERL version 5.14.0 or later is required for "getaddrinfo" support.
##
###########################################################################

List=$(cat $1)
clear
echo " Cofig a HP server and Installing OS "
BaseDIR="/root/hpilo"
LogFile=$BaseDIR/Output/${2:-output.$(basename $0).$(basename $1)}
Count=0
ArrayCountInc=0
Errmsg="POST in progress"
flag=true
Total=$(wc -l $1|awk '{print $1}')
DA=`date '+%D %H:%M'`
row=2
col=2
########################## Count down function ##########################
countdown() {
        clear
        echo "Check the KICKSTART script and wait for installing the OS on the server"
	msg="It may take time ......"
        tput cup $row $col
        echo -n "$msg"
        l=${#msg}

        l=$(( l+$col ))
        for i in {600..1}
        do
                tput cup $row $l
                echo -n "$i"
                sleep 1
        done
}


echo "---------------------New_Execution_of_Script at $DA-----------------"|tee -a  $LogFile

echo "ILO FW Details for $Total in $1 file " >> $LogFile
echo "$Total Systems to check" |tee -a  $LogFile
steps=(Set_Host_PowerOFF.xml Set_Boot_Mode.xml Set_One_Time_Boot_Order_to_NETWORK.xml Set_Host_PowerON.xml)
stepsHDD=(Set_Host_PowerOFF.xml Set_One_Time_Boot_Order_to_HDD.xml Set_Host_PowerON.xml)
ArrayCount=`echo ${#steps[@]}`

/root/hpilo/scripts/UpdateILOFirmware.sh $1




 for Host in $List; 
 do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    echo -n $Count : $Host   >> $LogFile
	 for step in "${steps[@]}" ;
 	do
	 ((ArrayCountInc++)) 
 	 Details=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/$step|grep Script)
	 echo " Doing $step for $Host $Details" |tee -a LogFile
		 if [ $ArrayCountInc -eq $ArrayCount ]
                	then
			echo "--------------------------------------------"
	                #echo "wait for next step , it may take time ......"
			echo "--------------------------------------------"
        	        fi

		sleep 1
	 done	
 done
# --wait for finishing installation Base OS 


countdown

 for Host in $List;
 do
	 mesg=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/Set_One_Time_Boot_Order_to_HDD.xml|grep "POST in progress"|cut -c14-29)
        if [[ "${mesg}" == "${Errmsg}" ]]
        then
                for step in "${stepsHDD[@]}" ;do
                        DetailsHDD=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f ILOXMLFile/$step|grep Script)
                        echo " Doing $step for $Host $DetailsHDD" |tee -a LogFile
                done
        fi
 done
        flag=false
