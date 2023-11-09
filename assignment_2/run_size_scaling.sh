#!/bin/bash
#SBATCH --no-requeue
#SBATCH --partition=EPYC
#SBATCH --cpus-per-task=64
#SBATCH --job-name=size_scaling
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=02:00:00
#SBATCH --output=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/slurm.out/size_scaling%j.out

# --> 64 per EPYC node, 12 per THIN node

# usage: sbatch run_size_scaling.sh <spread|close> <EPYC|THIN>
POLICY=$1
NODE=$2

# libraries
module load mkl
module load openBLAS/0.3.23-omp

SCRIPT_DIR=/u/dssc/dcapone/fast/FHPC-Assignment/assignment_2/
cd $SCRIPT_DIR

## !! consider the possibility of removing the make clean and make cpu:
#make clean
#make cpu

export OMP_PROC_BIND=$POLICY

echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_mkl_float_${POLICY}.csv"
echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_oblas_float_${POLICY}.csv"
echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_mkl_double_${POLICY}.csv"
echo "size,gflops" > "./results/size_scaling/size_scaling_${NODE}_oblas_double_${POLICY}.csv"  

# size of the matrix goes from 2000 to 20000, step of 1000
echo "Starting size scaling test on node $NODE using $POLICY policy\n"
for i in {0..18}
do  let size=$((2000+1000*$i))
    # fixing the size of the matrix, the test is executed 10 times
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