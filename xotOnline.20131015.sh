#!/bin/bash
#date >time_redu_f
#echo /home/xlp/iraf/focus.online.20120815/
#cp /home/jianyan/software/xgwacsoft/OTdetect/xotmatch.soft/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20121211/* ./

Dir_temp=$HOME/workspace/tempfile/result
echo "Please input your data directory"
echo "like this: /home/xlp/data/gwac/rawdata/20130113" 
#read Dir_rawdata
Dir_rawdata=$1
#Dir_rawdata=$HOME/data/gwac/rawdata/20130113

Dir_redufile=`pwd`

echo $Dir_rawdata
echo $Dir_temp
echo $Dir_redufile
./xmknewfile.sh
#if test -f $Dir_temp/refcom3d.cat
#then
#        cp $Dir_temp/refcom3d.cat ./
#        if test -f $Dir_temp/refcom.fit
#        then
#                cp $Dir_temp/refcom.fit ./
#                if test -f $Dir_temp/refcom.acc
#                then
#                        cp $Dir_temp/refcom.acc ./
#                        if test -f $Dir_temp/GwacStandall.cat
#                        then
#                                cp   $Dir_temp/GwacStandall.cat ./
#                                if test -f $Dir_temp/refcom1d.cat
#                                then
#                                        cp $Dir_temp/refcom1d.cat ./
#                                else
#                                        echo "====These is no refcom1d.cat in tempfile====="
#                                fi
#                        else
#                                echo "====These is no GwacStandall.cat in tempfile====="
#                        fi
#                else
#                        echo "====These is no refcom.acc in tempfile====="
#                fi
#        else
#                echo "====There is no refcom.fit in tempfile======"
#        fi
#else
#        echo "====These is no refcom3d.cat in tempfile====="
#fi
cd $Dir_rawdata
if test -r oldlist
then
        echo "oldlist exist"
else
        echo ' ' >oldlist
fi

while :
do
	ls *177d55*.fit | grep -v "dark" | grep -v "flat" | grep -v "bias" | grep -v "test" >newlist
	line=`diff oldlist newlist | grep  ">" | tr -d '>' | wc -l`
	if  [ "$line" -ne 0 ]
	then 
		echo "New image exits!"
		diff oldlist newlist | grep  ">" | tr -d '>' | column -t >listmatch1
#		newfile=`cat list | head -1`
#		cat listmatch1 | tail -2 | head -1 >list
		cat listmatch1 | head -1 >list
		cat list
	#	sleep 1
		cp list listmatch
		cat list >>oldlist
		sort oldlist >oldlist1
		mv oldlist1 oldlist
		#sleep 1
		FILE=`cat list`
#		for FILE in `cat list`
#		do
			du -a $FILE >mass
			fitsMass=`cat mass | awk '{print($1)}'`
			echo "fitsMass =" $fitsMass
			if [ "$fitsMass" -ne 18248 ]
			then
				echo "waiting ..."
				sleep 7
			else
				#du -a $FILE >mass
				#fitsMass=`cat mass | awk '{print($1)}'`
				#echo "fitsMass =" $fitsMass
				#continue
			
				cp $FILE $Dir_redufile
				cp listmatch $Dir_redufile
				gzip -f $FILE
				cd $Dir_redufile 
#				./xmatch6.sh  
			#	./xmatch11.cata.sh
				./xmatch11.cata.sh.20131013
#        			./xmatch3.CataSub.2timesxyMatch.sh
			fi
#		done
	else
		break
	fi

#	if  [ "$line" -eq 0 ]
#	then	
#		sleep 1	
#		continue
#	fi
	cd $Dir_rawdata
done
