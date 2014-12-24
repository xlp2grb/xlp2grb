#!/bin/bash
#date >time_redu_f
#echo /home/xlp/iraf/focus.online.20120815/
#cp /home/jianyan/software/xgwacsoft/OTdetect/xotmatch.soft/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20121211/* ./

Dir_temp=$HOME/workspace/tempfile/result
echo "Please input your data directory"
echo "like this: /home/xlp/data/gwac/rawdata/20130113" 
read Dir_rawdata
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
	ls *.fit *.fits | grep -v "dark" | grep -v "flat" | grep -v "bias" | grep -v "Dark" | grep -v "Flat" | grep -v "Zero" >newlist
	line=`diff oldlist newlist | grep  ">" | tr -d '>' | wc -l`
	if  [ "$line" -ne 0 ]
	then 
		echo "New image exits!"
		diff oldlist newlist | grep  ">" | tr -d '>' | column -t >listmatch1
#		newfile=`cat list | head -1`
#		cat listmatch1 | tail -2 | head -1 >list
		cat listmatch1 | tail -1 >list
		cat list
		sleep 1
		cp list listmatch
		cat listmatch1 >>oldlist
		sort oldlist >oldlist1
		mv oldlist1 oldlist
		#sleep 1
		FILE=`cat list`
			du -a $FILE >mass
			fitsMass=`cat mass | awk '{print($1)}'`
			echo "fitsMass =" $fitsMass
			if [ "$fitsMass" -ne 18248 ]
			then
				echo "waiting ..."
				sleep 7
				#du -a $FILE >mass
				#fitsMass=`cat mass | awk '{print($1)}'`
				#echo "fitsMass =" $fitsMass
				#continue
			
				cp $FILE $Dir_redufile
				cp listmatch $Dir_redufile
				gzip $FILE
				cd $Dir_redufile 
				ra1=`gethead $FILE "RA" `   # read out the ra from the image head 
				dec1=`gethead $FILE "DEC" ` # read out the dec from the image head
				
				ra_mount=`skycoor -d $ra1 $dec1 | awk '{print($1)}'`       # thransform the ra from time format to degree
				dec_mount=`skycoor -d $ra1 $dec1 | awk '{print($2)}'`     # transform the dec from time format to degree
				ID_MountCamara=`gethead $fitfile "IMAGEID" | cut -c15-17`
				echo $ra_mount $dec_mount $ID_MountCamara >newimageCoord
					
				./xcheck_skyfield                 #inputs are newimageCoord and GPoint_catalog, to check weather the skyfield exists in the point history
				wait
				RN=`wc xcheckResult | awk '{print($1)}'` # to get the line in the xcheckResult, if RN=0, it means no, else yes.
				if [ $RN -eq 0 ]                   # No
				then
					./xmktemp1.sh $FILE        # making the temp directly.
					wait
				else
					skyfield=`cat xcheckResult | awk '{print($8)}'`      # to tell which skyfield
					dir=$HOME/workspace/tempfile/$skyfield  # to tell where the skyfield is
					if test -r $dir
					then
						cp $dir/* ./                                 # to copy the temp files in the skyfield to the redufile
					else
						./xmktemp1.sh $FILE
						wait
						cp $dir/* ./
					fi
				fi
				
				#./xmatch11.cata.sh
				./xmatch11.cata.sh.20131013 
				wait
			fi
	fi

	if  [ "$line" -eq 0 ]
	then	
		sleep 2	
		continue
	fi
	cd $Dir_rawdata
done
