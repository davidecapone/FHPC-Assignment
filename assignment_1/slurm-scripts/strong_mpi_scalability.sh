#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="strong_MPI_scalability"
#SBATCH --get-user-env
#SBATCH --partition=EPYC
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/drsandro/fast/FHPC-Assignment/assignment_1/slurm.out/strong_MPI_scal_%j.out

module load openMPI/4.1.5/gnu/12.2.1

make clean
make clean_images
make

export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=1

k=10000     # size of the matrix (10000, 20000)
e=1         # evolution type (0, 1)

mpirun -np 2 ./main.x -i -k $k

echo size,cores,time > results/strong_MPI_static_$k.csv # remember to change the name of the file for each test

for i in {1..128}
do
    for j in {1..10}
    do
        echo -n $k,$i >> results/strong_MPI_static_$k.csv
	    mpirun -np $i --map-by core ./main.x -r -n 10 -e $e >> results/strong_MPI_static_$k.csv
    done
done

make clean
make clean_images
