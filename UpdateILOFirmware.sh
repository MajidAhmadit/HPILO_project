#!/bin/bash

List=$(cat $1)
DA=`date '+%D %H:%M'`
LogFile=${2:-output.$(basename $0).$(basename $1)}
echo "----------Start_Upgrading_the_ILO at $DA---------------------------------" |tee -a  $LogFile
Count=0
Total=$(wc -l $1|awk '{print $1}')
echo "=====================New Execution of Script at $DA =================">> $LogFile
echo "ILO FW Details for $Total in $1 file " >> $LogFile
echo "$Total Systems to check"




################################################################################
check_version ()
{
if [ $CurrentVersion != $LastVersion ]
 then
   echo " $DA CurrentVersion for $Host was $CurrentVersion , it should updated to $LastVersion" |tee -a $LogFile 
	flag=1  
else
   echo " $DA Current version for $Host is $CurrentVersion ,  and no need to be updated." |tee -a $LogFile
	flag=0
fi	
}

##################################################################################################


for Host in $List; do
    ((Count++))
    echo -n .
    (( Count % 10 )) || echo " $Count of $Total"
    echo -n $Count : $Host   >> $LogFile
    Product_Name=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/Get_Host_Data.xml |grep "Product Name"|awk -F "\"" '{print $4}')
echo $Product_Name	

case $Product_Name in

	ProLiant*BL*G*8* | ProLiant*DL*G*8* | ProLiant*G*9*|ProLiant*WS*G*8*)
		LastVersion=2.82
		Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/getquickstats.xml |grep -A 3 "<INDEX_1>"|grep "FIRMWARE_VERSION" | tail -l)
		CurrentVersion=`echo $Details|awk -F " " '{print $4}'|cut -c2-5`
		check_version
	        if [ $flag -eq 1 ] 
			then
			perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/Update_Firmware_ilo4.xml
		fi

        	;;
	ProLiant*G7* | ProLiant*BL*G7)
		LastVersion=1.94
		Details=$(perl locfg_v6.pl -s ${Host}-sc.ott.ciena.com -f scripts/getquickstats.xml |grep -A 3 "<INDEX_4>"|grep "FIRMWARE_VERSION" | tail -l)	
		CurrentVersion=`echo $Details|awk -F "\"" '{print $2}'|cut -c1-4`
		check_version
                 if [ $flag -eq 1 ] 
	                then
		  	perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/Update_Firmware_ilo3.xml 
		 fi
		;;

	ProLiant*G6* | ProLiant*BL*G6)
		LastVersion=2.33
		Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/getquickstats.xml |grep -A 3 "<INDEX_6>"|grep "FIRMWARE_VERSION" | tail -l)
                CurrentVersion=`echo $Details|awk -F " " '{print $4}'|cut -c2-5`
		check_version
                 if [ $flag -eq 1 ] 
			then
                   	perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/Update_Firmware_ilo2.xml 
 		 fi 
	        ;;
     
	ProLiant*DL*G*10* )
		LastVersion=2.44
                Details=$(perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/getquickstats.xml |grep -A 3 "<INDEX_1>"|grep "FIRMWARE_VERSION" | tail -l)
                CurrentVersion=`echo $Details|awk -F " " '{print $4}'|cut -c2-5`
                check_version
                if [ $flag -eq 1 ]
			then
                        perl locfg.pl -s ${Host}-sc.ott.ciena.com -f scripts/Update_Firmware_ilo5.xml
                fi

        ;;
    *)
        echo " Don't know the firmware version of $Product_Name for $Host"|tee -a $LogFile
# 	dialog --ascii-lines --begin 10 70 --backtitle "Processing" --title "ILO Version Updating " --extra-button --extra-label "Cancel" --msgbox "Couldn't Find the Firmware Version of $Product_Name for $Host.Please Correct it and Continue..." 10 70
        ;;
esac


done
echo "-----------Finish_Upgrading_the_ILO at $DA---------------------------------"|tee -a  $LogFile
