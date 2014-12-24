#!/bin/bash
DIR_data=`pwd`
fitfile=$1
darkname=$2
flatname=$3
#============================
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >>login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo $fitfile $darkname $flatname
echo "ccdpro(images=\"$fitfile\", output=\"  \",trim-,zerocor-,darkcor+,flatcor+,dark=\"$darkname\",flat=\"$flatname\")" >>login.cl
echo logout >> login.cl
cl < login.cl >xlogfile
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data
