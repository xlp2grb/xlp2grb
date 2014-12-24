#!/bin/bash

        DIR_data=$1
        OUTPUT_new=$2
	tempmatchstars=$3
	matchflag=$4
	NumToler=$5
	NumSep=$6
	inprefix=$7
	xNpixel=$8
	fitorder=$9
	OUTPUT_geoxytran2=$10
	OUTPUT_geoxytran3=$11
	imagetmpNsd=$12
	imagetransNsd=$13	
        rm -rf mattmp transform.db
#====================================================
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl

        #position match for the first time with triangles
#        echo $OUTPUT_new $tempmatchstars
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=$NumToler, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=$NumSep, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
        echo "geoxytran(\"$OUTPUT_geoxytran2\", \"$OUTPUT_geoxytran3\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv mattmp $imagetmpNsd
        mv transform.db $imagetransNsd

