#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=THIN
#SBATCH --cpus-per-task=12
#SBATCH --job-name=ss_thin
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/slurm.out/size_scaling%j.out

# usage: sbatch run_size_scaling.sh <spread|close> <EPYC|THIN>
POLICY=$1
NODE=THIN

module load mkl
module load openBLAS/0.3.23-omp

SCRIPT_DIR=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/
cd $SCRIPT_DIR

#make clean
#make cpu

export OMP_PROC_BIND=$POLICY

#echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_mkl_float_${POLICY}.csv"
#echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_oblas_float_${POLICY}.csv"
#echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_mkl_double_${POLICY}.csv"
#echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_oblas_double_${POLICY}.csv"  


echo "Starting size scaling test on node $NODE using $POLICY policy"
for i in {0..18}

do  let size=$((2000+1000*$i))

    for _ in {1..10}
    do
        echo "size: $size"
        cd $SCRIPT_DIR
        # mkl float
        ./gemm_mkl_float.x $size $size $size >> "./results/size_scaling/size_scaling_${NODE}_mkl_float_${POLICY}.csv"
        echo "mkl float done"
        # openblas float
        ./gemm_oblas_float.x $size $size $size >> "./results/size_scaling/size_scaling_${NODE}_oblas_float_${POLICY}.csv"
        echo "openblas float done"
        # mkl double
	    ./gemm_mkl_double.x $size $size $size >> "./results/size_scaling/size_scaling_${NODE}_mkl_double_${POLICY}.csv"
        echo "mkl double done"
        # openblas double
        ./gemm_oblas_double.x $size $size $size >> "./results/size_scaling/size_scaling_${NODE}_oblas_double_${POLICY}.csv"
        echo "openblas double done"
    done
done