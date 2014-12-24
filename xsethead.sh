newccdtype=DARK
for fitfile in `cat list`
do
	sethead -kr X ccdtype=$newccdtype  $fitfile
done
