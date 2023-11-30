#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="w_mpi_scal"
#SBATCH --get-user-env
#SBATCH --partition=THIN
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --nodelist=thin[010]

module load architecture/Intel
module load openMPI/4.1.4/gnu/12.2.1

cd ../
make clean
make image
make

export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=16

evolution=1
dir=results
sizes=(10000 10000 14142 17321 20000 22361 24496 26458 28284 30000)

echo size,cores,time > $resultdir/weak_mpi_scal_static_ev_16omp-threds.csv

to=9
for i in {1..9}
do
    mpirun -np 1 ./main.x -i ${sizes[i]}
    for j in {1..5}
    do
        echo -n ${sizes[i]},$i >> $dir/weak_mpi_scal_static_ev_16omp-threds.csv
        mpirun -np $i --map-by core ./main.x -r -n 10 -e $evolution -t >> $dir/weak_mpi_scal_static_ev_16omp-threds.csv
    done
done

make clean
make image
