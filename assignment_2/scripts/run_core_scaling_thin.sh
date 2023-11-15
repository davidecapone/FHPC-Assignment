#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=THIN
#SBATCH --cpus-per-task=12
#SBATCH --job-name=cs_thin
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/slurm.out/core_scaling%j.out

# usage: sbatch run_core_scaling_thin.sh <spread|close>
POLICY=$1
NODE=THIN

module load mkl
module load openBLAS/0.3.23-omp

SCRIPT_DIR=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/
cd $SCRIPT_DIR

#make clean
#make cpu

export OMP_PLACES=cores
export OMP_PROC_BIND=$POLICY

#echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_mkl_float_${POLICY}.csv"
#echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_oblas_float_${POLICY}.csv"
#echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_mkl_double_${POLICY}.csv"
#echo "n_cores,size,gflops" > "./results/core_scaling/core_scaling_${NODE}_oblas_double_${POLICY}.csv"


echo "Starting core scaling test on node $NODE using $POLICY policy"
max_cores=12
for ((i=1; i<=$max_cores; i++)) do	
	
	export OMP_NUM_THREADS=$i
	cd $SCRIPT_DIR

	for _ in {1..10} 
	do
		echo "testing with $i core..."
		# this process foreach library:
		# - we run the executables
		# - we save the output 
		# - we parse the output and save it in the csv file (n_cores, size, gflops)

		: << 'END'
		IFS=',' read -ra ADDR <<< "$(./gemm_mkl_float.x 10000 10000 10000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_mkl_float_${POLICY}.csv
		echo "mkl float done"
END

		: << 'END'
		IFS=',' read -ra ADDR <<< "$(./gemm_oblas_float.x 10000 10000 10000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_oblas_float_${POLICY}.csv
		echo "openblas float done"
END

		: << 'END'
		IFS=',' read -ra ADDR <<< "$(./gemm_mkl_double.x 10000 10000 10000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_mkl_double_${POLICY}.csv
		echo "mkl double done"
END
	
		: << 'END'
		IFS=',' read -ra ADDR <<< "$(./gemm_oblas_double.x 10000 10000 10000)"
		size=${ADDR[0]}
		gflops=${ADDR[1]}
		echo "$i,$size,$gflops" >> ./results/core_scaling/core_scaling_${NODE}_oblas_double_${POLICY}.csv
		echo "openblas double done"
END
	done
done