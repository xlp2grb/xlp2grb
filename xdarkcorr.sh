#!/bin/bash
DIR_data=`pwd`
fitfile=$1
darkname=$2
#============================
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >>login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo $fitfile $darkname
echo "ccdpro(images=\"$fitfile\", output=\"  \",trim-,zerocor-,darkcor+,flatcor-,dark=\"$darkname\")" >>login.cl
echo logout >> login.cl
cl < login.cl >xlogfile
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data
