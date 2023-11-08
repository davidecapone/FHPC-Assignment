#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=EPYC
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/drsandro/fast/Assignment/exercise2/slurm.out/%j.out

# Load libraries

module load mkl
module load openBLAS/0.3.23-omp

# Define working directory

export wd=/u/dssc/drsandro/fast/Assignment/exercise2

# Define binding policies (spread/close)

export OMP_PROC_BIND=spread

# Run tests

cd $wd
make clean
make cpu

## Create csv files and initialize column names

echo "size,gflops" > ./results/size_scaling_EPYC_mkl_float_spread.csv
echo "size,gflops" > ./results/size_scaling_EPYC_oblas_float_spread.csv
echo "size,gflops" > ./results/size_scaling_EPYC_mkl_double_spread.csv
echo "size,gflops" > ./results/size_scaling_EPYC_oblas_double_spread.csv    

## The size of the matrix goes from 2000 to 20000, with a step of 1000

for i in {0..18}
do  let size=$((2000+1000*$i))

    ## For each matrix size, the test is run 10 times	
	
    for j in {1..10}
    do
	
	## Write on csv files the size of the matrix, the gflops obtained using MKL and the gflops obtained using OpenBLAS.

        echo $size
        ./gemm_mkl_float.x $size $size $size >> ./results/size_scaling_EPYC_mkl_float_spread.csv
        ./gemm_oblas_float.x $size $size $size >> ./results/size_scaling_EPYC_oblas_float_spread.csv
	    ./gemm_mkl_double.x $size $size $size >> ./results/size_scaling_EPYC_mkl_double_spread.csv
        ./gemm_oblas_double.x $size $size $size >> ./results/size_scaling_EPYC_oblas_double_spread.csv
    done
done
