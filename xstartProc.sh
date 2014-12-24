#!/bin/bash

for ((i=1; i<13; i++))
do
	gnome-terminal -t "xlot6cOnline.sh.batch $i" -x bash -c "xlot6cOnline.sh.batch $i; exec bash" &
done

echo "12 processes started completely."
