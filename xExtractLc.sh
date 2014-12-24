#!/bin/bash
DIR_data=`pwd`
#inputfile=star1.cat
inputfile=$1
cp $inputfile inputstarlist.cat
outputfile=`echo $inputfile | sed 's/\.cat/.cat.output/'`
echo $outputfile
#ls *tran2 >listtran2
for FILE in `cat listtran2`
do

	FITFILEcat=$FILE
	FITFILE=`echo $FITFILEcat | sed 's/\.tran2//'`
	FITFILEn=`echo $FITFILEcat | sed 's/\.fit.tran2/e.fit/'`
	echo $FITFILE
	cat $FITFILEcat | grep -v '99.0000' > starinnewimg.lc.cat1
	./xstarcross.lc
#	ls output_inputstarlist.cat
	RN1=`wc output_inputstarlist.cat | awk '{print($1)}'`
#	echo $RN1
	if [ $RN1 -gt 0 ]
	then
#		echo "#################"
		dateobs=`gethead $FITFILE "DATE-OBS" | sed 's/T/ /' | awk '{print($1)}'`
		timeobs=`gethead $FITFILE "DATE-OBS" | sed 's/T/ /' | awk '{print($2)}'`
#		echo $dateobs $timeobs
		sethead -nkr X DATE-OBS=$dateobs ut=$timeobs ra="00"  dec="00" epoch="2000" $FITFILE
	        cd $HOME/iraf
       		cp -f login.cl.old login.cl
	        echo noao >> login.cl
        	echo astutil >> login.cl
	        echo "cd $DIR_data" >> login.cl
	        echo "setjd(\"$FITFILEn\", date=\"DATE-OBS\",time=\"ut\")" >>login.cl
	        echo logout >> login.cl
	        cl < login.cl >xlogfile
        	cd $HOME/iraf
	        cp -f login.cl.old login.cl
	        
		cd $DIR_data
		gethead $FITFILEn "jd" >obstimejd
		paste obstimejd output_inputstarlist.cat >temp1
		cat $outputfile temp1 >temp2
		mv temp2 $outputfile 
	fi
	rm -rf output_inputstarlist.cat
#	rm -rf $FITFILEn
done
