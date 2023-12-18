#!/bin/bash

DA=`date '+%D %H:%M'`
BaseDIR="/root/hpilo"
LogFile=$BaseDIR/Output/${2:-output.$(basename $0).$(basename $1)}
Total=$(wc -l $1|awk '{print $1}')
Errmsg="POST in progress"
steps=(Set_Host_PowerOFF.xml Set_Server_Name.xml Set_Host_PowerON.xml)
Count=0
flag=true


   clear
echo "#########################################################################"
echo "         Set Servername for $1 at $DA  " |tee -a  $LogFile
echo 
echo " to execute this script, you should have a file                        "
echo "  with 2 column: IP Name                                               "
echo " 1.1.1.1 onxlXXXX                                                      "
echo " 2.2.2.2 onxlYYYY                                                      "
echo "#########################################################################"
echo "$Total Systems to check" |tee -a  $LogFile




while IFS= read -r line
do
  IP=`echo $line|awk -F " " '{print $1}'`
  Srvnm=`echo $line|awk -F " " '{print $2}'`
   ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
		
echo $Srvnm		
		#while flag=true
		#do 
		sed -i "s/\<SERVER_NAME value =\"ServerName\"/SERVER_NAME value =\"$Srvnm\"/g" $BaseDIR/ILOXMLFile/Set_Server_Name.xml
		Details=$(perl locfg_v6.pl -s $IP -f ILOXMLFile/Set_Server_Name.xml|grep "MESSAGE"|tail -n 1|grep "POST in progress"|cut -c14-29)
		echo -e "for $IP ,Servername changed to $Srvnm \t$Details" |tee -a $LogFile

		if [[ "${Details}" == "${Errmsg}" ]]
		then
		echo "POST in progress, trying to power off the server"  |tee -a LogFile
		   for step in "${steps[@]}" ;do
			echo -e "doing $step "
	         	Details=$(perl locfg_v6.pl -s $IP -f ILOXMLFile/$step |grep -i script)
		   done
		

		echo -e "for $IP ,Servername changed to $Srvnm \t$Details" |tee -a $LogFile
			
	#	else 
		#falg=false
		fi
		#done
		sed -i "s/\<SERVER_NAME value =\"$Srvnm\"/SERVER_NAME value =\"ServerName\"/g" $BaseDIR/ILOXMLFile/Set_Server_Name.xml




done < $1
