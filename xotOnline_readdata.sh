#!/bin/bash
redu_dir=/data2/workspace/redufile/matchfile
cd $redu_dir
echo $redu_dir
rm -rf *
#rm -rf ../subfile/*

#copy the code to the reduction files
cp -r ~/newxgwacmatchsoft/* ./
cp -r ~/newxgwacmatchsoft/* ../subfile/

#echo "delete all the files in trim files [yes/no]:"
#read chyesno
#if [ "$chyesno"x = "yes"x ]
#then
#	rm -rf /data2/workspace/redufile/trimsubimage/*
#fi

#=============================
#kill and restart the ds9 
ds9_num=`ps -all | grep "ds9" | wc -l`
echo $ds9_num
if [ $ds9_num -gt 0 ]
then
	echo "delete ds9"
	for((i=0;i<$ds9_num;i++))
	do
		ds9Pad=`ps -all | grep "ds9" | awk '{print($5)}'| head -1`
		echo $ds9Pad
		kill -9 $ds9Pad
	done
fi
ds9 &
#============================

while :
do
        begintime=`date -u +%k`

        if [ $begintime -ge 8 ] #from 16:00:00 to 08:00:00 of local time at Xinglong obs.
        then
                if [  $begintime -le 24  ]
                then
                        echo $begintime 
                        echo $begintime >>listtimeold
			ipaddress=`ifconfig | grep "inet" |  awk '{if($5=="broadcast")print($2)}' | cut -c11-12`
			case $ipaddress in
			11) filename_prefix=`echo "M1_01"`;;
			12) filename_prefix=`echo "M1_02"`;;
			13) filename_prefix=`echo "M2_03"`;;
			14) filename_prefix=`echo "M2_04"`;;
			15) filename_prefix=`echo "M3_05"`;;
			16) filename_prefix=`echo "M3_06"`;;
			17) filename_prefix=`echo "M4_07"`;;
			18) filename_prefix=`echo "M4_08"`;;
			19) filename_prefix=`echo "M5_09"`;;
			20) filename_prefix=`echo "M5_10"`;;
			21) filename_prefix=`echo "M6_11"`;;
			22) filename_prefix=`echo "M6_12"`;;
			esac
			utdate=`date -u +%Y%m%d | cut -c3-8`
			wholefilename=`echo "/data/"$filename_prefix"_"$utdate`
			if test -r xcheckResult
			then
				rm -rf xcheckResult
			fi
			if test ! -r $wholefilename
			then
				mkdir $wholefilename
			fi
                        ./xotOnline.sh  $wholefilename 
                else
                        echo "######" >>listtimeold
                        date >>listimetold
                        sleep 600
                fi
        else
                echo "@@@@@@@@" >>listtimeold
                date >>listtimeold
                sleep 600
        fi
done

