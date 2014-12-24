DIR_data=`pwd`

if test -r oldlist
then
        echo "oldlist exist"
else
        touch oldlist
fi

if test -r bakfile
then
        echo "bakfile exist"
else
        mkdir bakfile
fi


while :
do
	cd $DIR_data
	date >reduct.log
	if test ! -r *.fits
	then
		echo "no" `date` >redu.log
		sleep 3
		continue
	else
		ls *.fits >newlist
	fi
	line=`diff oldlist newlist | grep  ">" | tr -d '>' | wc -l`
	if  [ "$line" -ne 0 ]
        then
		fitfile=`diff oldlist newlist | grep  ">" | tr -d '>' | head -1` 
		ls $fitfile >>oldlist	
		sleep 2
		cd $HOME/iraf
		cp -f login.cl.old login.cl
		echo noao >> login.cl
		echo image >> login.cl
		echo "cd $DIR_data" >> login.cl
		echo "display(image=\"$fitfile\",frame=1)" >>login.cl #display newimage in frame 1
		echo logout >> login.cl
		cl < login.cl >xlogfile
		cd $HOME/iraf
		cp -f login.cl.old login.cl
		cd $DIR_data
		mv $fitfile bakfile
	else
		sleep 2
	fi
done
