for file in *.batch; do 
echo "	../../CPLEX_Studio126/cplex/bin/x86-64_linux/cplex -f $file > $file.log 2>&1 ";
done
