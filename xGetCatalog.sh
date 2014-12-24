#!/bin/bash
#author: to get the USNO B1.0 catalog by the code of hans
# 20131115

cenccfile=$1
dir_reductionCCD=$2
CCDfile=$3
cctran_dir=$HOME/tempfile/reddir/$CCDfile
result_dir=$HOME/tempfile/result
#getCatalog_dir=$HOME/han/remote_py_v1.1-xinglong
getCatalog_dir=$HOME/han/catalogue
mktempfile_dir=$HOME/tempfile/soft
pres_dir=`pwd`
#dir_reduction=$HOME/reddir
accfile=`echo $cenccfile | sed 's/\.cencc1/.acc/'`
FITFILE=`echo $cenccfile | sed 's/\.cencc1/.fit/'`

MiniRadiusBright=11
MinilowMagBright=7
MinilargerMagBright=8
MinidimMagBright=14.0
MinilowRadiusBright=30
MinilargerRadiusBright=50
MiniRadiusTempBright=12.7
MinilowMagTemp=1
MinilargerMagTemp=14.0

BGWACRadiusBright=6
BGWAMlowMagBright=9
BGWAMlargerMagBright=10
BGWAMdimMagBright=14.0
BGWAMlowRadiusBright=30
BGWAMlargerRadiusBright=50
BGWAMRadiusTempBright=6.5
BGWAMlowMagTemp=1
BGWAMlargerMagTemp=17

if test -r $cenccfile
then
	echo $FITFILE
	rm -rf $cctran_dir/refcom.fit
#	echo "new test !"
#	echo `pwd`
#	echo $FITFILE
#	imhead  $FITFILE
#	echo $cctran_dir

        cp $FITFILE $cctran_dir/refcom.fit
	cp $accfile $cctran_dir/refcom.acc
	cp $cenccfile $cctran_dir/refcom.cencc1
	cp GPoint_catalog $cctran_dir
#	echo "imhead refcom.fit"
#	imhead $cctran_dir/refcom.fit
	ID_MountCamara=`gethead $FITFILE "IMAGEID" | cut -c14-17`
	ID_CamaraType=`echo $ID_MountCamara | cut -c1-1`
	ra1=`cat $cenccfile | head -1 | awk '{print($1)}'`
	dec1=`cat $cenccfile | head -1 | awk '{print($2)}'`
	Ra=`skycoor -d $ra1 $dec1 | awk '{printf("%.5f",$1)}'`
	Dec=`skycoor -d $ra1 $dec1 | awk '{printf("%.5f",$2)}'`
	
	cd $cctran_dir
	rm -rf bright*.txt  temp*.txt
	cd $getCatalog_dir
	if [ "$ID_CamaraType"x = "M"x ] #for mini-gwac
	then
		sleep 1
		python isolated_bright_star_extract.py $cctran_dir $Ra $Dec $MiniRadiusBright $MinilowMagBright $MinilargerMagBright $MinidimMagBright $MinilowRadiusBright $MinilargerRadiusBright  
		wait
                if test -s bright*.txt
                then
                        echo "bright*.txt is ready" 
                else
			#python brightstar_extract_p.py $getCatalog_dir $Ra $Dec 12.7 6 9 14.0 30 50
			sleep1
			python isolated_bright_star_extract.py $cctran_dir $Ra $Dec $MiniRadiusBright $MinilowMagBright $MinilargerMagBright $MinidimMagBright $MinilowRadiusBright $MinilargerRadiusBright
                        wait
                fi

		echo "python template_extract.py  "  $cctran_dir $Ra $Dec  $MiniRadiusTempBright $MinilowMagTemp $MinilargerMagTemp
		#python template_extract_u.py $getCatalog_dir $Ra $Dec 12.7 1 14.0 
		sleep 1
		python template_extract.py $cctran_dir $Ra $Dec $MiniRadiusTempBright $MinilowMagTemp $MinilargerMagTemp 
		wait
                if test -s temp*.txt
                then
                        echo "temp*.txt is ready"
                else
			sleep 1
			python template_extract.py $cctran_dir $Ra $Dec $MiniRadiusTempBright $MinilowMagTemp $MinilargerMagTemp
                        wait
                fi
		echo `date`

	elif [ "$ID_CamaraType"x = "G"x ]  #for GWAC
	then
		python isolated_bright_star_extract.py $cctran_dir $Ra $Dec $BGWACRadiusBright $BGWAMlowMagBright $BGWAMlargerMagBright $BGWAMdimMagBright $BGWAMlowRadiusBright $BGWAMlargerRadiusBright 
		wait
		if test -s bright*.txt
		then
			echo "bright*.txt is ready"		
		else
			python isolated_bright_star_extract.py $cctran_dir $Ra $Dec $BGWACRadiusBright $BGWAMlowMagBright $BGWAMlargerMagBright $BGWAMdimMagBright $BGWAMlowRadiusBright $BGWAMlargerRadiusBright
			wait	
		fi
		python template_extract.py $cctran_dir $Ra $Dec $BGWAMRadiusTempBright $BGWAMlowMagTemp  $BGWAMlargerMagTemp
		wait
		if test -s temp*.txt
		then
			echo "temp*.txt is ready"
		else
			python template_extract.py $cctran_dir $Ra $Dec $BGWAMRadiusTempBright $BGWAMlowMagTemp  $BGWAMlargerMagTemp
			wait
		fi
	else
		echo "======================"
		echo "Image header is not right, please check"
		echo "======================"
		continue
		#break
	fi

	cd $cctran_dir
	if [ ! -s temp*.txt ] || [ ! -s bright*.txt ]
	then
		echo "no temp*.txt or bright*.txt" >errorimage.flag
		mv errorimage.flag $dir_reductionCCD
		rm -rf bright*.txt temp*.txt
		cd $dir_reductionCCD
		continue
	else
	#	rm -rf  $cctran_dir/refall.txt $cctran_dir/refstand.txt	
	        mv temp*.txt refall.txt
	        mv bright*.txt refstand.txt
	
	#       cd $cctran_dir
	        GP_dir=`echo $ID_MountCamara"_"$Ra"_"$Dec`
		mkdir $result_dir"/"$GP_dir
	#	ls refall.txt refstand.txt refcom.acc refcom.fit
		cp $mktempfile_dir/* $cctran_dir 
		cd $cctran_dir
	#	echo "pwd"
#	        xcctran_temp.sh refall.txt refstand.txt refcom.acc refcom.fit $result_dir/$GP_dir
	#	echo "imhead second refcom.fit"
	#	imhead refcom.fit
		sh xcctran_temp.sh refall.txt refstand.txt refcom.acc refcom.fit $GP_dir
		wait
		
#	        mv refcom3d.cat refcom1d.cat refcom.fit GwacStandflux.cat refcom3d_noupdate.cat refcom_subbg.fit GPoint_catalog $result_dir/$GP_dir
		
	        echo "Temp at $GP_dir sky field is completed"
	fi
fi
#cd $pres_dir
