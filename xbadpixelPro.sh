#!/bin/bash
#Author: xlp at 20130328
#To get the hot pixels from Dark.fit which is produced from dark images
#the output file is named as badpixelFile.db

ejmin=5
ejmax=3045

sex Dark.fit  -c  xmatchdaofind.sex -DETECT_THRESH 2.5 -ANALYSIS_THRESH 2.5 -CATALOG_NAME Dark.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME Dark_bg.fit
cat Dark.sex | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax )print($1,$2)}' ejmin=$ejmin ejmax=$ejmax >badpixelFile.db
wc badpixelFile.db
