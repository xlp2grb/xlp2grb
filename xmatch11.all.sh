for fitsimg in `cat listmatch1`
do
	ls $fitsimg >listmatch
	./xmatch11.cata.sh.20131013
done
