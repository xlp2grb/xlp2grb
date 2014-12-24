cat list2frame.list | awk '{printf("%f %f %s %s %f %f \n ",$5,$6,$7,$8,$14,$15)}' |tr -s '\n' | sort -n -k 1 | sort -n -k 2 | uniq | column -t>updaterefcom3d.cat
