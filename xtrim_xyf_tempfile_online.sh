#!/bin/bash
#to cut the subimage from tempfile

trimsubimage_dir=/data2/workspace/redufile/trimsubimageForTemp
if test ! -r $trimsubimage_dir
then
    mkdir $trimsubimage_dir
fi
cd $trimsubimage_dir
rm -rf *
echo "cp -r ~/newxgwacmatchsoft/* $trimsubimage_dir"
cp -r ~/newxgwacmatchsoft/* $trimsubimage_dir
ls 
#====================
xget2otlistfromxy ( )
{
        if test -s $SecondOTlist
        then
                mv $SecondOTlist before.lst
        fi
        wget -O $SecondOTlist $Command_SecondOTlist
	date >>ot2.log
	wc $SecondOTlist >>ot2.log
        wait
        if test -s $SecondOTlist
        then
                echo "===xtrim_xyf_tempfile.sh====="
                if test -s before.lst
                then
                        cat $SecondOTlist before.lst >new.lst
                        mv new.lst $SecondOTlist
                        rm -rf before.lst
                fi
                #./xtrim_xyf.sh  $SecondOTlist
                #wait
                ./xtrim_xyf_tempfile.sh  $SecondOTlist 
		wait
		sleep 5
        else
                echo "no $SecondOTlist exist"
		sleep 5
        fi
}
#====================
while :
do
	begintime=`date -u +%k`
	if [ $begintime -ge 8 ]
	then
		if [  $begintime -le 24  ]
		then
#	                echo $begintime 
	                echo $begintime >>listtimeold
	
			if test ! -r M*.fit
			then
				sleep 10
				continue
			fi
			ccdtype=`ls M*.fit | tail -1  | cut -c4-5 | awk '{print("M"$1)}'`
			SecondOTlist=`echo $ccdtype".ref.lst"`
			Command_SecondOTlist=`echo  http://190.168.1.25/getCutImageList.action?dpmName=$ccdtype`
	#		Command_SecondOTlist=`echo  http://190.168.1.125:8080/gwac/getCutImageList.action?dpmName=$ccdtype`
			xget2otlistfromxy
			wait
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
#===================
