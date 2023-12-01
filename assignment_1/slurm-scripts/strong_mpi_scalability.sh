#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="MPI-s_scalability"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --time=02:00:00

module load architecture/Intel
module load openMPI/4.1.5/gnu/12.2.1

ls
make clean
make clean_images
make

export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=1


k=10000
evolution=0

./main.x -i -k $k
dir=results

echo size,cores,time > $dir/strong_mpi_scal_ordered_ev_size$k.csv


for i in {1..24}
do
    for j in {1..5}
    do
        echo -n $k,$i >> $dir/strong_mpi_scal_ordered_ev_size$k.csv
	mpirun -np $i --map-by core ./main.x -r -n 10 -e $evolution -t >> $dir/strong_mpi_scal_ordered_ev_size$k.csv
    done
done

make clean
make image
