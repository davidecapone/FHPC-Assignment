#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="omp_scal"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --nodelist=thin[008]

module load architecture/Intel
module load openMPI/4.1.4/gnu/12.2.1

cd ../
make clean
make image
make

export OMP_PLACES=cores
export OMP_PROC_BIND=close

k=10000
evolution=0

mpirun -np 2 ./main.x -i -k $k
dir=results

echo size,OMP-threads,time > $dir/omp_scal_ordered_ev_size$k.csv

to=12
for i in {1..$to}
do
	export OMP_NUM_THREADS=$i
	for j in {1..5}
	do
		echo -n $k,$i >> $dir/omp_scal_ordered_ev_size$k.csv
	        mpirun -np 1 --map-by node --bind-to socket ./main.x -r -n 10 -e $evolution -t >> $dir/omp_scal_ordered_ev_size$k.csv
	done
done

make clean
make image
