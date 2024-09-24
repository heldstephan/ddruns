gawk '{print "/mnt/ddcolors/build/ddcolors -s 2 -n -w IPs/"$1".edd.lp /mnt/instances/" $1 " > ddlogs/" $1 ".log 2>&1" ;}' instances.txt | parallel -j 8

