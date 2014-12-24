#!/bin/bash
#this filter is only for those matched more than 3 times
dir_now=`pwd`
echo "usage: ./xotcheckUSNOB.sh resall_M1AA_matchchb.log M1AA  [ depends on the refcom.acc]" 
echo "Have you copy the right refcom.acc? [y/n]:"
read chyesno
if [ "$chyesno"x = "y"x ]
then
	echo "Great"
else
	exit 1
fi
resall=$1  #output from xmatch11.cata.sh.20140311
mcid=$2  #$1 is M1AA like that
echo $resall $mcid
dateReduc=`date +%Y%m%d%H%M%S`
filterRes=`echo $mcid"_"$dateReduc`
otxymag=`echo $mcid"_"$dateReduc".xymag"`
otxy=`echo $mcid"_"$dateReduc".xy"`
otxyradec=`echo $mcid"_"$dateReduc".xyradec"`
otradec=`echo $mcid"_"$dateReduc".radec"`
result_dir=/data/workspace/resultfile
#==============================
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
newdictory=`echo $year$month$day`
cd $result_dir
if test ! -d $newdictory
then
        mkdir $newdictory
fi

cd $newdictory
pwd
if test ! -d otres
then
        mkdir otres
fi
Dir_otres=`echo $result_dir"/"$newdictory"/otres"`
cd $dir_now
echo $dir_now
#=========================
ipfile=`echo "ip_address_"$mcid".dat"`
ipadress=`ifconfig | grep "inet" |  awk '{if($5=="broadcast")print($2)}'`
echo $ipadress $Dir_otres >$ipfile
#========================
temp_ip=`echo 190.168.1.40`
temp_dir=`echo /home/gwac/otfile`
#=======================
echo $resall $filterRes
./starclassify $resall  $filterRes 1
if test -s $otxymag
then
	cat $otxymag | awk '{print($1,$2)}'>$otxy
	cat $otxy | xargs -n 2 xcctranXY2RaDec.sh >$otxyradec
	wait
	cat $otxyradec | awk '{print($3,$4)}' | column -t >$otradec
	./xatcopy_remote.f $ipfile $otradec $temp_ip $temp_dir
	wait
	cp $otxyradec $Dir_otres
fi
