#!/bin/bash
# Purpose: Work on a group of HP servers
# Author: Majid Ahmadi
# --------------------------------------------------------

clear
echo " Work on a group of HP servers "
echo 
SrciptSrc=/root/hpilo/scripts
ScriptList=`ls -1 $SrciptSrc`
rm /tmp/ScrList > /dev/null 2>&1
 for Selection in $ScriptList ; do
#echo $Selection
let Count=$Count+1
 echo "$Count: $Selection " >> /tmp/ScrList
 ScrArray[$Count]=$Selection
done 

pr -3 --width=80 -t /tmp/ScrList
        echo
        echo "0: Exit"
        echo
        echo -n "Select Script to run : "
        read Choice
        echo
        if [ $Choice -eq 0 ] ; then
            echo "Exiting..."
            exit
        elif [ $Choice -le $Count ] ; then
            ScrName=${ScrArray[Choice]}
	    echo "$ScrName"
        fi


	echo
        echo "0: Exit"
        echo
        echo -n "Input File name that include the ServerNames(The Selected Script in privious step , will run for this Filename ant Servers in file) :  "
	read Filename


	read -p "The script $ScrName will run on $Filename, Do you Agree(Y/N)?  " answer
        case $answer in
            [Yy]*)
		echo
	 	echo " Start running $SrciptSrc/$ScrName $Filename  " 
	 	sh $SrciptSrc/$ScrName $Filename
   		;;  
            [Nn]*) echo "Aborted" ; exit ;;
        esac
	

