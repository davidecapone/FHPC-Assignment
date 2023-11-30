#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="conway"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00

# number of MPI processes
n_MPI_proc=12

module purge
module load architecture/Intel
module load openMPI/4.1.5/gnu/12.2.1 

# or
#module load architecture/AMD
#module load openMPI/4.1.5/gnu/12.2.1 

# remove main.x if it exists and all the .o files in obj/ directory
make clean
#make image
make

# set the environment variables
# according to your needs
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=8

k=10000             # playground size
e=1                 # evolution type, 0 ordered, 1 random
n=15                # number of steps to be calculated
s=1                 # every how many steps take a snapshot (0 means only at the end)
f=fileName.pbm      # name of the file to be either read or written
                    # use -f $filename to load an initial state from the file
                    # use the option -i to generate it

# run:
mpirun -np $n_MPI_proc ./main.x -i -k $k
mpirun -np $n_MPI_proc ./main.x -r -n $n -s $s -e $e