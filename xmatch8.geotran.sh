#!/bin/bash
#Author: xlp at 20130101
#function: to match the newimage to the reference image with xyxymatch
#image match is only donw with 1 times.
# modifed by xlp at 20130118
DIR_data=`pwd`
#========================================================================
for FILE in `cat listsub`
do
	FITFILE=$FILE
	tran2=`echo $FITFILE | sed 's/\.fit/.2sd.fit/'`
	imagetrans3sd=`echo $FITFILE | sed 's/\.fit/.fit.trans3sd_re/'`
	inprefix=`echo $FITFILE | sed 's/\.fit//'`
	echo $FITFILE $imagetrans3sd 
	
#=========================================================================
        echo `date` "All geotran from image to temp"
	if test ! -s $imagetrans3sd
	then
		break
	fi
        rm -rf $tran2  
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
	echo "geotran(\"$FITFILE\", \"$tran2\", \"$imagetrans3sd\", \"$inprefix\")" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile 
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        cd $DIR_data
	rm -rf $FITFILE
	echo "***image transformaton finished***"
	
#	echo `date` "test if the new image number is larger than N. if yes, making the combination"
	echo "test the image num."
	ls $tran2 >>newcomlist
	if test -r oldcomlist
	then
		:
	else
		#echo '' >oldcomlist
		#sed '/^$/d' oldcomlist >oldcomlist1
		#mv oldcomlist1 oldcomlist
		touch oldcomlist
	fi
	diff oldcomlist newcomlist | grep  ">" | tr -d '>' | sed 's/\ //g' | sed '/^$/d' >listcom_temp
	line=`cat listcom_temp | wc -l`
	cat listcom_temp
	if [ $line -lt 5 ]
	then
		echo "the number of new image is" $line
	else
		cat listcom_temp | head -5 >listcom
		cat listcom >>oldcomlist
		cat oldcomlist | uniq  >oldcomlist1
		mv oldcomlist1 oldcomlist
		echo `date` "To combine the new 5 images"
		./xcom_withoutshift.sh listcom
		wait
#		echo `date` "to do the subimage" 
#		./xmatch8.sub.sh &
	fi
done
