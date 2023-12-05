#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="strong_MPI_scalability"
#SBATCH --get-user-env
#SBATCH --partition=THIN
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

k=10000
evolution=0

mpirun -np 2 ./main.x -i -k $k

echo size,cores,time > results/strong_MPI_ordered_$k.csv

for i in {1..24}
do
    for j in {1..10}
    do
        echo -n $k,$i >> results/strong_MPI_ordered_$k.csv
	    mpirun -np $i --map-by core ./main.x -r -n 10 -e $evolution -t >> results/strong_MPI_ordered_$k.csv
    done
done

make clean_images

k=20000

mpirun -np 2 ./main.x -i -k $k

for i in {1..24}
do
    for j in {1..10}
    do
        echo -n $k,$i >> results/strong_MPI_ordered_$k.csv
	    mpirun -np $i --map-by core ./main.x -r -n 10 -e $evolution -t >> results/strong_MPI_ordered_$k.csv
    done
done

make clean
make clean_images
