#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="conw_test"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/drsandro/fast/FHPC-Assignment/assignment_1/slurm.out/correctness_test_%j.out

# number of MPI processes
n_MPI_proc=5

module purge
#module load architecture/AMD
module load openMPI/4.1.5/gnu/12.2.1 

make clean
make clean_images
make

# set the environment variables
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=12

k=100           # playground size
e=1           # evolution type, 0 ordered, 1 static
n=3           # number of steps to be calculated
s=1           # every how many steps take a snapshot (0 means only at the end)

# run:
mpirun -np $n_MPI_proc ./main.x -i -k $k
mpirun -np $n_MPI_proc ./main.x -r -n $n -s $s -e $e