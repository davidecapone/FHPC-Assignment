#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=EPYC
#SBATCH --cpus-per-task=64
#SBATCH --job-name=core_scaling
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/slurm.out/core_scaling%j.out

# --> 64 per EPYC node, 12 per THIN node

# usage: sbatch run_core_scaling.sh <spread|close> <EPYC|THIN>
POLICY=$1
NODE=$2

# libraries
module load mkl
module load openBLAS/0.3.23-omp

SCRIPT_DIR=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/
cd $SCRIPT_DIR

## !! consider the possibility or removing the make clean and make cpu:
#make clean
#make cpu

export OMP_PROC_BIND=$POLICY

echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_mkl_float_${POLICY}.csv"
echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_oblas_float_${POLICY}.csv"
echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_mkl_double_${POLICY}.csv"
echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_oblas_double_${POLICY}.csv"

# used cores goes from 1 to max_cores
max_cores=64
echo "Starting core scaling test on node $NODE using $POLICY policy"

for ((i=1; i<=$max_cores; i++)) do	
	# set number of cores
	set OMP_NUM_THREADS=$i
	cd $SCRIPT_DIR

	for _ in {1..10} 
	do
		echo "n.core: $i"
		# - we run the executable
		# - we save the output 
		# - we parse the output and save it in the csv file (n_cores, size, gflops)
		# this process for each library:
		IFS=',' read -ra ADDR <<< "$(./gemm_mkl_float.x 15000 15000 15000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_mkl_float_${POLICY}.csv
		echo "mkl float done"

		IFS=',' read -ra ADDR <<< "$(./gemm_oblas_float.x 15000 15000 15000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_oblas_float_${POLICY}.csv
		echo "openblas float done"

		IFS=',' read -ra ADDR <<< "$(./gemm_mkl_double.x 15000 15000 15000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_mkl_double_${POLICY}.csv
		echo "mkl double done"

		IFS=',' read -ra ADDR <<< "$(./gemm_oblas_double.x 15000 15000 15000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_oblas_double_${POLICY}.csv
		echo "openblas double done"
	done
done