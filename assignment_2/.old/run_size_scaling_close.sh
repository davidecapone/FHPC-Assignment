#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=EPYC
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/drsandro/fast/Assignment/exercise2/slurm.out/%j.out

# load libraries
module load mkl
module load openBLAS/0.3.23-omp

# parent path: assignment_2
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
make clean
make cpu

# CLOSE = close threads over cores
export OMP_PROC_BIND=close


echo "size,gflops" > ./results/size_scaling_EPYC_mkl_float_close.csv
echo "size,gflops" > ./results/size_scaling_EPYC_oblas_float_close.csv
echo "size,gflops" > ./results/size_scaling_EPYC_mkl_double_close.csv
echo "size,gflops" > ./results/size_scaling_EPYC_oblas_double_close.csv    

: <<'END'
# size of the matrix goes from 2000 to 20000, step of 1000
for i in {0..18}
do  let size=$(( 2000+1000*$i ))
    # fixing the size of the matrix, the test is executed 10 times
    for _ in {1..10}
    do        
        echo $size
        # mkl float
        ./gemm_mkl_float.x $size $size $size >> ./results/size_scaling_EPYC_mkl_float_close.csv

        # openblas float
        ./gemm_oblas_float.x $size $size $size >> ./results/size_scaling_EPYC_oblas_float_close.csv

        # mkl double
	    ./gemm_mkl_double.x $size $size $size >> ./results/size_scaling_EPYC_mkl_double_close.csv

        # openblas double
        ./gemm_oblas_double.x $size $size $size >> ./results/size_scaling_EPYC_oblas_double_close.csv
    done
done
END
