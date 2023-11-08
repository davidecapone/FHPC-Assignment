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

export OMP_PROC_BIND=close

# Run tests

cd $wd
make clean
make cpu

## Create csv files and initialize column names

echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_mkl_float_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_oblas_float_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_mkl_double_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_oblas_double_spread.csv

## The number of used cores goes from 1 to 64

for i in {1..64}
do	
	
	## Set number of cores

	export OMP_NUM_THREADS=$i

	## For each number of cores, the test is run 10 times

	for _ in {1..10}
	do
		echo|set /p=$i, >> ./results/core_scaling_EPYC_mkl_float_spread.csv
		./gemm_mkl_float.x 15000 15000 15000 >> ./results/core_scaling_EPYC_mkl_float_spread.csv
		echo|set /p=$i, >> ./results/core_scaling_EPYC_oblas_float_spread.csv
                ./gemm_oblas_float.x 15000 15000 15000 >> ./results/core_scaling_EPYC_oblas_float_spread.csv
		echo|set /p=$i, >> ./results/core_scaling_EPYC_mkl_float_spread.csv
		./gemm_mkl_double.x 15000 15000 15000 >> ./results/core_scaling_EPYC_mkl_double_spread.csv
		echo|set /p=$i, >> ./results/core_scaling_EPYC_oblas_float_spread.csv
                ./gemm_oblas_double.x 15000 15000 15000 >> ./results/core_scaling_EPYC_oblas_double_spread.csv
        done
done
