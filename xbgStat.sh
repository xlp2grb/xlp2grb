#!/bin/bash

if test -r bgbright.cat
then
	rm -rf bgbright.cat
fi

for file in `cat list`
do
	cat $file | head -1 | awk '{print($5)}' >>bgbright.cat
done

cat -n bgbright.cat >bgbright.cat1
mv bgbright.cat1 bgbright.cat

