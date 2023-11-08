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

# working directory:
export wd=/u/dssc/drsandro/fast/FHPC_2019-2020/Assignment_2

# SPREAD = spread threads over cores
export OMP_PROC_BIND=spread

cd $wd
make clean
make cpu

# initialize column names
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_mkl_float_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_oblas_float_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_mkl_double_spread.csv
echo "n_cores,size,gflops" > ./results/core_scaling_EPYC_oblas_double_spread.csv

# number of used cores goes from 1 to max_cores
max_cores=64

for i in {1..$max_cores}
do	
	# set number of cores
	export OMP_NUM_THREADS=$i

	# fixing the number of cores, the test is executed 10 times
	for _ in {1..10}
	do
		# mkl float
		echo|set /p=$i, >> ./results/core_scaling_EPYC_mkl_float_spread.csv
		./gemm_mkl_float.x 15000 15000 15000 >> ./results/core_scaling_EPYC_mkl_float_spread.csv

		# openblas float
		echo|set /p=$i, >> ./results/core_scaling_EPYC_oblas_float_spread.csv
        ./gemm_oblas_float.x 15000 15000 15000 >> ./results/core_scaling_EPYC_oblas_float_spread.csv

		# mkl double
		echo|set /p=$i, >> ./results/core_scaling_EPYC_mkl_float_spread.csv
		./gemm_mkl_double.x 15000 15000 15000 >> ./results/core_scaling_EPYC_mkl_double_spread.csv

		# openblas double
		echo|set /p=$i, >> ./results/core_scaling_EPYC_oblas_float_spread.csv
        ./gemm_oblas_double.x 15000 15000 15000 >> ./results/core_scaling_EPYC_oblas_double_spread.csv
        done
done