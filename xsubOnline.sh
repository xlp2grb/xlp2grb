#!/bin/bash
#Author:xlp at 20130113
#to check the if a new image exist
#and then do the image subtraction

#date >time_redu_f
#echo /home/xlp/iraf/focus.online.20120815/
#cp /home/jianyan/software/xgwacsoft/OTdetect/xotmatch.soft/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20121211/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20130131/* ./

#Dir_temp=$HOME/workspace/tempfile/result
#Dir_rawdata=$HOME/share/gwac/20130113
#Dir_redufile=`pwd`
#echo $Dir_rawdata
#echo $Dir_temp
#echo $Dir_redufile
./xmknewfile.sh
if test -r oldlist
then
        echo "oldlist exist"
	rm -rf oldlist
	touch oldlist
else
	touch oldlist
fi
rm -rf oldcomlist newcomlist listcom


xcheckimg ( )
{
	if test ! -r M*.fit
	then
		sleep 5
		continue
	else
		ls M*.fit  | grep -v "bg" | grep -v "2sd" | grep -v "sub" | grep -v "ref" | grep -v "_5_" | grep -v "bias" | grep -v "flat" | grep -v "flux" >newlist
		line=`diff oldlist newlist | grep  ">" | tr -d '>' | wc -l`
		if  [ "$line" -ne 0 ]
		then 
			echo "New image exits!"
			diff oldlist newlist | grep  ">" | tr -d '>' | column -t | sort | uniq | head -1 >listsub
			cat listsub >>oldlist
			sort oldlist >oldlist1
			mv oldlist1 oldlist
			./xmatch8.geotran.sh
			wait
		elif  [ "$line" -eq 0 ]
		then	
			sleep 5	
			continue
		fi
	fi
}
xcheckobstime ( )
{
	begintime=`date -u +%k`
	if [ $begintime -ge 8 ]
	then
		if [  $begintime -le 24  ]
                then
#                        echo $begintime 
                        echo $begintime >>listtimeold
			xcheckimg
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
}

while :
do
	xcheckobstime
done
