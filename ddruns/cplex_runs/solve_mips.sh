for file in *.batch; do 
echo "	../../cplex128/bin/x86-64_linux/cplex -f $file > $file.log 2>&1 ";
done
