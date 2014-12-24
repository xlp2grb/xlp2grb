#!/bin/bash
DIR_data=`pwd`
#RES_data=../png
#inputfile=star1.cat
inputfile=$1
cp $inputfile inputstarlist.cat
#outputfile=`echo $inputfile | sed 's/\.cat/.cat.output/'`
#echo $outputfile
#ls *tran2 >listtran2
for FILE in `cat listtran2`
do

	FITFILEcat=$FILE
	FITFILE=`echo $FITFILEcat | sed 's/\.tran2//'`
	FITFILEn=`echo $FITFILEcat | sed 's/\.fit.tran2/e.fit/'`
	echo "***************************"
	echo $FITFILE
	if test -r $FITFILEn
	then
		gethead $FITFILEn "jd" >obstimejd
	else
                dateobs=`gethead $FITFILE "DATE-OBS" | sed 's/T/ /' | awk '{print($1)}'`
                timeobs=`gethead $FITFILE "DATE-OBS" | sed 's/T/ /' | awk '{print($2)}'`
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

	fi
	cat obstimejd 
#	sleep 5
	cat $FITFILEcat | grep -v '99.0000' > starinnewimg.lc.cat1
#./xstarcrosslclist 
	./xstarcrosslclistres
done
#===========================================
echo "@@@@@@@@ To get the light curves for star lists @@@@@@@@@@@@@@@@@@@@"
ls abc*.cat.output >listcatoutput
for file in `cat listcatoutput`
do
	Filename=$file
	xcoord=`cat $Filename | head -1 |  sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($2)}'`
	ycoord=`cat $Filename | head -1 | sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($3)}'`
	Rmag=`cat $Filename  | head -1 | sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($4)}'`
	./xcctranXY2RaDec.sh $xcoord $ycoord >resxy2radec
	ra=`cat resxy2radec | awk '{print($5)}'`
	dec=`cat resxy2radec | awk '{print($6)}'`
	#cat $Filename | awk '{print($1-2456300,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$8-$14+$18)}' | sort -n -k 1 |  column -t >resfilenameoutput
	cat $Filename | awk '{print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$11-$17+$21)}' | sort -n -k 1 |  column -t >resfilenameoutput
	
	cat resfilenameoutput | tail -3 | head -1 | awk '{print($22)}' >resfilenameoutput_flare
	cat resfilenameoutput | tail -2 | head -1 | awk '{print($22)}' >>resfilenameoutput_flare
	cat resfilenameoutput | tail -1 | awk '{print($22)}' >>resfilenameoutput_flare
	cat resfilenameoutput_flare | tr '\n' ' ' | awk '{if(($1-$2)>0.3 && $3<$2)print($1-$2)}' >flare_point  # the brightness is increasing with an ampli. lager then 0.3 
	lflare_p=`cat flare_point | awk '{print($1)}'`
	echo $lflare_p
#./xaveragerms
#mv resfilenameoutput $Filename

if [ $lflare_p = 1 ] #it might be a flare star
then
lcname=`echo "xlc_"$Filename".png"`
sourcename=`echo $ra"_"$dec"_"$Rmag`
gnuplot << EOF
set term png
set output "$lcname"
set xlabel "jd-2456300 (days)"
set ylabel "White mag collibrated by a comp star in USNOB1.0 Rmag"
set title '$sourcename'
set grid
set yrange [] reverse
plot "resfilenameoutput" u 1:22 w lp t ''
EOF
#displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#kill -9 $displayPadNum
#display $lcname &
#cp $lcname ../png

cat resfilenameoutput | tail -1 | awk '{print($1,$2,$3)}' |  column -t >>resfilenameoutput_flare
echo "==================="
cat resfilenameoutput_flare | tr '\n' ' ' | awk '{print($4,$5,$6,$1,$2,$3)}'
echo "==================="
else
	echo "No flare candidate"
fi
done

