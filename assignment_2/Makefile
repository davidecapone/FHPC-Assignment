### MKL libraries
MKL= -L${MKLROOT}/lib/intel64  -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl

### OpenBLAS libraries 
OPENBLASROOT=${OPENBLAS_ROOT}

cpu: gemm_ss_mkl_float.x gemm_ss_oblas_float.x gemm_ss_mkl_double.x gemm_ss_oblas_double.x gemm_cs_mkl_float.x gemm_cs_oblas_float.x gemm_cs_mkl_double.x gemm_cs_oblas_double.x 

# Create executables for all libraries (MKL, OpenBLAS), and for different precisions (float, double)
gemm_ss_mkl_float.x: gemm_ss.c
	gcc -DUSE_FLOAT -DMKL $^ -m64 -I${MKLROOT}/include $(MKL)  -o $@

gemm_ss_oblas_float.x: gemm_ss.c
	gcc -DUSE_FLOAT -DOPENBLAS $^ -m64 -I${OPENBLASROOT}/include -L/${OPENBLASROOT}/lib -lopenblas -lpthread -o $@ -fopenmp

gemm_ss_mkl_double.x: gemm_ss.c
	gcc -DUSE_DOUBLE -DMKL $^ -m64 -I${MKLROOT}/include $(MKL)  -o $@

gemm_ss_oblas_double.x: gemm_ss.c
	gcc -DUSE_DOUBLE -DOPENBLAS $^ -m64 -I${OPENBLASROOT}/include -L/${OPENBLASROOT}/lib -lopenblas -lpthread -o $@ -fopenmp

gemm_cs_mkl_float.x: gemm_cs.c
	gcc -DUSE_FLOAT -DMKL $^ -m64 -I${MKLROOT}/include $(MKL)  -o $@

gemm_cs_oblas_float.x: gemm_cs.c
	gcc -DUSE_FLOAT -DOPENBLAS $^ -m64 -I${OPENBLASROOT}/include -L/${OPENBLASROOT}/lib -lopenblas -lpthread -o $@ -fopenmp

gemm_cs_mkl_double.x: gemm_cs.c
	gcc -DUSE_DOUBLE -DMKL $^ -m64 -I${MKLROOT}/include $(MKL)  -o $@

gemm_cs_oblas_double.x: gemm_cs.c
	gcc -DUSE_DOUBLE -DOPENBLAS $^ -m64 -I${OPENBLASROOT}/include -L/${OPENBLASROOT}/lib -lopenblas -lpthread -o $@ -fopenmp

clean:
	rm -rf *.x
