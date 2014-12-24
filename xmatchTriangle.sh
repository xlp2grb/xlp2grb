#!/bin/bash
#Author: xlp at 20130402
DIR_data=`pwd`

        FITFILE=$1
        OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`
        imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
        imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
        inprefix=`echo $FITFILE | sed 's/\.fit//'`
        OUTPUT_geoxytran1=`echo $FITFILE | sed 's/\.fit/.fit.tran1/'`
        echo $FITFILE 


        cat allres1 | awk '{if(($3-$5)/$6>30 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres0
        matchflag=triangles
        Nbstar=10 #set 10*10 regions to extract the bright stars to match each other
        Ng=2
        fitorder=2
        tempmatchstars=refcom1d.cat
        #==========================================================================
        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`
	
        xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
        yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
        for((i=$Ng;i<($Nbstar-$Ng);i++))
        do
        {
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
                        cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -5 | column -t >Res$i$j
                done
        } &
        wait
        done
        cat Res* >$OUTPUT_new
        wc $OUTPUT_new
        rm -rf mattmp
        echo `date` "triangle match"
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo $OUTPUT_new $tempmatchstars
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=60, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=10, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=2, reject=2.5, inter-)" >>login.cl
        echo "geoxytran(\"allres1\", \"$OUTPUT_geoxytran1\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv mattmp $imagetmp1sd
        mv transform.db $imagetrans1sd

	cat  $imagetrans1sd | grep "shift" | awk '{print($2)}' | tr '\n' '  ' > newxyshift.cat
        echo >> newxyshift.cat
	cat newxyshift.cat
