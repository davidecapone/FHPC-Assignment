#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="OMP_scalability"
#SBATCH --get-user-env
#SBATCH --partition=EPYC
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/drsandro/fast/FHPC-Assignment/assignment_1/slurm.out/omp_scal_%j.out

module load openMPI/4.1.5/gnu/12.2.1

make clean
make clean_images
make

export OMP_PLACES=cores
export OMP_PROC_BIND=close

k=10000
e=1
n=10

mpirun -np 2 ./main.x -i -k $k
dir=results
echo size,OMP-threads,time > $dir/omp_static_$k.csv

for i in {1..64}
do
	export OMP_NUM_THREADS=$i
	for j in {1..10}
	do
		echo -n $k,$i >> $dir/omp_static_$k.csv
	        mpirun -np 1 --map-by node --bind-to socket ./main.x -r -n $n -e $e >> $dir/omp_static_$k.csv
	done
done

make clean
make clean_images
