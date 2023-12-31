/**
* @file run.c
* @brief This file contains the functions needed to run the program
* @details 
**/

#include<stdio.h>
#include<stdlib.h>
#include<omp.h>
#include<time.h>
#include<mpi.h>
#include"run.h"
#include"ordered_evolution.h"
#include"static_evolution.h"
#include"read_write.h" 

#if defined(_OPENMP)
    #define CPU_TIME ({struct  timespec ts; clock_gettime( CLOCK_REALTIME, &ts ),\
	    (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;})
    #define CPU_TIME_th ({struct  timespec myts; clock_gettime( CLOCK_THREAD_CPUTIME_ID, &myts ),\
	    (double)myts.tv_sec + (double)myts.tv_nsec * 1e-9;})
#else
#define CPU_TIME ({struct  timespec ts; clock_gettime( CLOCK_PROCESS_CPUTIME_ID, &ts ),\
    (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;})
#endif

/**
* Check what kind of evolution is required and then call the corresponding function.
* @param fname name of the file containing the initial game field
* @param k size of the game field
* @param n number of iterations
* @param s step to save a snapshot
* @param e 0: ordered evolution, 1: static evolution
*/
void run(const char *fname, unsigned const int k, unsigned const int n, unsigned const int s, const char e) {
    int mpi_provided_thread_level;
    MPI_Init_thread(NULL, NULL, MPI_THREAD_FUNNELED, &mpi_provided_thread_level);

    if ( mpi_provided_thread_level < MPI_THREAD_FUNNELED ) {
        printf("Error: MPI thread support is lower than the demanded\n");
        MPI_Finalize();
        exit(1);
    }

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (e==0) { // ordered evolution
        double start = CPU_TIME;
        MPI_Finalize();
        run_ordered(fname, k, n, s);
        double end = CPU_TIME;
        if (rank == 0) printf(",%f\n", end-start);
        return;
    } else { // static evolution
        run_static(fname, k, n, s, rank, size);
        return;
    }
    return;
}
