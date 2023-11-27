#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="conway"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00

make clean
make

# change the module load commands
# according to the architecture (Intel or AMD)
module purge
module load architecture/Intel
module load openMPI/4.1.4/gnu/12.2.1

# To know each slurm.out file belongs to which job
date
hostname
whoami
pwd


# number of MPI processes
n_proc=12

# set the environment variables
# according to your needs
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=8

size_grid=10000     # the size of the grid
evolution=1         # 0: ordered, 1: static
steps_snapshot=1    # every how many steps to take a snapshot
steps=15            # number of steps to evolve
file=file.pbm

# run the MPI program
mpirun -np $n_proc ./main.x -i -k $size_grid
mpirun -np $n_proc ./main.x -r -n $steps -s $steps_snapshot -e $evolution