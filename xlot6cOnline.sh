#!/bin/bash
#author: xlp
#aim: to build the temp image and temp catalog automatically.
#input are image and ipfiles in which the ip and terminal direction is set.
#Other softwares and files are needed:
# xautocopy_remote.f      -----to copy the results back automatically.
# xGetCatalog.sh
# list6c
# xcctran_temp.sh
# brightstar_extract_p.py
# template_extract_u.py
# lot6c2.py
# xTransRAtoXYacc.sh

#if [ $# -ne 1  ]
#then
#	echo "usage:   xlot6cOnline.sh 3 [mini-gwac CCD number(1-12)] "
#fi

xsentcatalogerror (  )
{
          xautocopy_remote.f errorimage.flag $ip  $term_dir
          wait
          rm -rf errorimage.flag $newfile
          mv GPoint_catalog_old GPoint_catalog
          continue 
	# break
}

xgetcatalog ( )
{
                 echo "update the GPoint_catalog"
                 #need to add the code to update the catalog immediately, and then copy it to the data reduction node.
                 #The premeters in the GPoint_catalog are ra_sky dec_sky ra_mount dec_mount ra_sky_dc_mount ID_Camara
                 ra_s=`cat $cenccfile | head -1 | awk '{print($1)}'`
                 dec_s=`cat $cenccfile | head -1 | awk '{print($2)}'`
                 ra_sky=`skycoor -d $ra_s $dec_s | awk '{printf("%.5f",$1)}'`
                 dec_sky=`skycoor -d $ra_s $dec_s | awk '{printf("%.5f",$2)}'`
                 cp GPoint_catalog GPoint_catalog_old
                 echo $ra_sky $dec_sky $ra_mount $dec_mount $ra_sky"_"$dec_sky $ID_MountCamara | grep -v "^_" | awk '{if($3!="_")print($1,$2,$3,$4,$5,$6)}' >>GPoint_catalog 
                 #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
                 echo "xGetCatalog.sh ------"
                 xGetCatalog.sh $cenccfile $dir_reductionCCD  $CCDfile
                 wait
		 cd $dir_reductionCCD
                 if test -s errorimage.flag
                 then
          		echo "no temp*.txt or bright*.txt "
			xsentcatalogerror
		 else
                        echo "xTransRAtoXYacc.sh -------"
                        xTransRAtoXYacc.sh $newfile
                        wait
		 fi
}


xmakenewtemp (  )
{
	#===================================================
	 echo "To check the image quality"
         xcheckimgquality
         wait
	#=====================================================

        accfile=`echo $newfile | sed 's/\.fit/.acc/'`
        cenccfile=`echo $newfile | sed 's/\.fit/.cencc1/'`
	#delete the RA and DEC keywords
	delhead -o $newfile RA DEC   
	ls $newfile >list
        echo "----------first-----------"
	sleep 1
        lot6c2.py $ID_MountCamara list 
        wait
        if test  -s $cenccfile
        then
		xgetcatalog
	else
		sleep 1
                echo "----------second-----------"
                lot6c2.py $ID_MountCamara list  
                wait
		if test -s $cenccfile
		then
			xgetcatalog
		else
			sleep 1
	                echo "----------Third-----------"
	                lot6c2.py $ID_MountCamara list  
	                wait
			if test -s $cenccfile
			then
				xgetcatalog
			else
				echo "no cenccfile after lot6c2.py " >errorimage.flag
	                	echo "no cenccfile after lot6c2.py "
        		        xsentcatalogerror
			fi
	        fi
        fi

}

xcheckimgquality ( )
{
	rm -rf image.sex
	sex $newfile  -c  daofind.sex  -CATALOG_NAME image.sex -DETECT_THRESH 5 -ANALYSIS_THRESH 5
	Num_imgquality=`wc -l image.sex | awk '{print($1)}'`
	if [ $Num_imgquality -lt 5000 ]
	then
		echo $newfile "is not good for the temp making ! "
		echo $newfile "is not good !" >errorimage.flag
                xautocopy_remote.f  errorimage.flag $ip  $term_dir
                wait
                rm -rf errorimage.flag list image.sex  $newfile $ipaddressname
		continue
	fi
}



xmaketemp ( )
{
	echo $1
#        echo $1 >>oldlist
        ID_MountCamara=`gethead "IMAGEID" $newfile | cut -c14-17`
	Iccdtype=`gethead $newfile "CCDTYPE"`
	ra_m=`gethead $newfile "RA" `
	dec_m=`gethead $newfile "DEC" `
	ra_mount=`skycoor -d $ra_m $dec_m | awk '{print($1)}'`
	dec_mount=`skycoor -d $ra_m $dec_m | awk '{print($2)}'`
	
	ipaddressname=`echo "ip_address_"$ID_MountCamara".dat"`
	ip=`cat $ipaddressname | awk '{print($1)}'`
	term_dir=`cat $ipaddressname | awk '{print($2)}'`
	if [ $Iccdtype != "OBJECT"  ]
	then
		#echo "it is NOT an object file"
		#ipaddressname=`echo "ip_address_"$ID_MountCamara".dat"`
		#ip=`cat $ipaddressname | awk '{print($1)}'`
		#term_dir=`cat $ipaddressname | awk '{print($2)}'`
		echo "CCDTYPE: "$Iccdtype "is not OBJECT" >errorimage.flag
		echo "CCDTYPE: "$Iccdtype "is not OBJECT"
		xautocopy_remote.f  errorimage.flag $ip  $term_dir
		wait
		rm -rf errorimage.flag list $newfile $ipaddressname
		continue
		#break
		
	else
		echo "it is an object file"
        	mv list $newfile $ipaddressname $dir_reductionCCD

        	cd $dir_reductionCCD
		rm -rf gototemp.xy gototemp.sex Tempfile.cat 
		#====================
		if test -s GPoint_catalog
		then
			echo $ra_mount $dec_mount $ID_MountCamara >newIdRADEC.cat
			xCrossGPointImage			
			#/home/gwac/gwacsoft/xCrossGPointImage 
			#output is Tempfile.cat in which rasky decsky ramount decmount rasky_decsky
			if test -s Tempfile.cat
			then
				echo "Have template files for this FOV and this Camera"
				temp_dir=`cat Tempfile.cat | awk '{print($6"_"$5)}'`
			#	result_dir=$HOME/tempfile/result
				GP_dir=`echo $result_dir"/"$temp_dir`
	#			ipaddressname=`echo "ip_address_"$ID_MountCamara".dat"`
	#			ip=`cat $ipaddressname | awk '{print($1)}'`
	#			term_dir=`cat $ipaddressname | awk '{print($2)}'`
				xautocopy_remote.f $GP_dir $ip  $term_dir
				wait
				xautocopy_remote.f $GP_dir/GPoint_catalog  $ip  $term_dir
				wait
				rm -rf Tempfile.cat newIdRADEC.cat $newfile
				continue
			else
				echo "No template files for this FOV and this Camera"
				xmakenewtemp
			fi
		else
			touch GPoint_catalog
			xmakenewtemp
		fi
	fi
}

checkimage ( )
{ 
	diff oldlist newlist | grep  ">" | tr -d '>' | head -1 >list
	line=`cat list | wc -l`
	if  [ "$line" -ne 0 ]
	then 
		newfile=`cat list`
		echo $newfile >>oldlist
		#sleep 5
		xmaketemp $newfile
#	#	sleep 5
#		du -a $newfile  >mass
#	        fitsMass=` cat mass | awk '{print($1)}'`	
#	        echo "fitsMass =" $fitsMass
#	#	until [  $fitsMass -gt 18248 ] 
#	#	do
#        #                xmaketemp $newfile
#	#		echo "@@@@@@@@"
#	#		du -a $newfile  >mass
#	#		fitsMass=` cat mass | awk '{print($1)}'`
#	#		echo "fitsMass =" $fitsMass
#	#	done
#		if [ "$fitsMass" -gt 18248 ]
#		#if [ "$fitsMass" -gt 36490 ]
#		#if [ "$fitsMass" -eq 36496 ]
#		then 
#			echo "@@@@@@@@"
#			sleep 3
#			xmaketemp $newfile
#		else	
#			sleep 5
#			xmaketemp $newfile
#		fi
	else
		#break
		continue
	fi
}

echo "Temp making is preparing: "
filelist=$HOME/gwacsoft/list6c
dir_reduction=$HOME/reddir
result_dir=$HOME/tempfile/result
#dir_source=`head -$1 $filelist | tail -1`
#cd $dir_source
#CCDfile=`echo $dir_source | cut -c20-24`
#dir_reductionCCD=`echo $dir_reduction/$CCDfile`
#echo "delte the oldlist"
for dir_source in `cat $filelist`
do
	cd $dir_source
	if test -r oldlist
	then
		rm -rf oldlist
		touch oldlist
	else
		touch oldlist
	fi
done
#echo "delete the oldlist, finished!"
#=====================================================
#echo "Process id: $1;	Work dir: $dir_source"
while :
do
#=====================================================
        for dir_source in `cat $filelist`
        do
			#echo $dir_source
			#dir_source=`head -$1 $filelist | tail -1`
			cd $dir_source
			CCDfile=`echo $dir_source | cut -c20-24`
			dir_reductionCCD=`echo $dir_reduction/$CCDfile`			
#=====================================================
			cd $dir_source
			#echo "new process is beginning"
			
			if test -r  *.fit
			then

			 	ls *.fit >newlist
				echo "There is an image in current folder"
				sleep 3
			 	checkimage
				wait
			fi
			sleep 1
			#echo "The image is processed!"
#=====================================================
        		#echo $dir_source
		#	date >reduct.log
		#        if test ! -r  *.fit
        	#	then
	        #        	echo `date` >redu.log
        	#        	echo "No new images"
                #		continue
        	#	else
		#                ls *.fit >newlist
		#		echo "New images"
                #        	checkimage
                #		wait
		#	fi
        done
done

