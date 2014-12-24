#!/bin/bash
#author:xlp
#date: 20140506
#aim: to upload the subimage to the server
if [ $# -ne 5 ]
then
	echo "usage: xmkupload.sh matchlog imagefit imagepng ccdtype dateobs"
	exit 1
fi
matchlog=$1
imagefit=$2
imagepng=$3

ccdtype=$4
dateobs=$5

echo "otlist=$1
starlist=
origimage=
cutimages=$2,$3" >data-upload-config.properties



echo "curl  http://10.36.1.154:8080/svom/uploadAction.action -F dpmName=$4  -F currentDirectory=$5 -F configFile=@data-upload-config.properties -F fileUpload=@$1 -F fileUpload=@$2  -F fileUpload=@$3 " >xupload.sh

sh xupload.sh


