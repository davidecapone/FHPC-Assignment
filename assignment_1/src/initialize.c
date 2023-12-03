/**
* @file initialize.c
* @brief This file contains the functions needed to initialize the playground
* @details 
**/

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<omp.h>
#include<mpi.h>
#include "initialize.h"
#include "read_write.h"

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
* Checks if the executable is runned on one or more processes, 
* then consequently calls the correct function to initialize the playground.
* @param fname name of the file that's going to be written to initialize the playground
* @param k size of the squre matrix that's going to rapresent the playground
* @param t should print the time taken by the function
**/
void initialize(const char *fname, unsigned const int k, const int t) {

    int mpi_provided_thread_level;
    MPI_Init_thread(NULL, NULL, MPI_THREAD_FUNNELED, &mpi_provided_thread_level);
    if ( mpi_provided_thread_level < MPI_THREAD_FUNNELED ) 
    {
        printf("Error: MPI thread support is lower than the demanded\n");
        MPI_Finalize();
        exit(1);
    }
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (t==0)
    {
        if (size == 1) // size is the number of MPI processes TODO: change variable names
        {
            MPI_Finalize();
            initialize_serial(fname, k);
            return; 
        }
        else
        {
            initialize_parallel(fname, k, rank, size);
            MPI_Finalize();
            return;
        }
    } 
    else // t==1
    if (size == 1)
    {
        MPI_Finalize();
        double start = CPU_TIME;
        initialize_serial(fname, k);
        double end = CPU_TIME;
        printf(",%f\n", end-start);
        return; 
    }
    else
    {
        double start = CPU_TIME;
        initialize_parallel(fname, k, rank, size);
        double end = CPU_TIME;
        if (rank == 0)
            printf(",%f\n", end-start);
        MPI_Finalize();
        return;
    } 
}

/**
* Initializes the playground with a random configuration of cells and 
* and writes the result to a file.
* The probability of a cell to be alive is 15%.
* @param fname name of the file that's going to be written to initialize the playground
* @param k size of the squre matrix that's going to rapresent the playground
*/
void initialize_serial(const char *fname, unsigned const int k) {
    char *world; 
    #pragma omp parallel shared(world, k, fname)
    {
        world = (char *)malloc(k*k*sizeof(char));
        int seed = time(NULL);
        // int seed = 42;  // for testing purposes
        srand(seed);
        #pragma omp parallel for schedule(static) shared(world, k)
            for (unsigned long i = 0; i < k*k; i++)
                world[i] = rand() % 100 < 15 ? 255 : 0;
        write_pbm(world, 255, k, k, fname);
    }
    free(world);
    return; 
}

/**
* Initializes the playground with a random configuration of cells 
* and writes the result to a file. The procedure is done in parallel.
* The probability of a cell to be alive is 15%.
* @param fname name of the file that's going to be written to initialize the playground
* @param k size of the squre matrix that's going to rapresent the playground
* @param rank rank of the process
* @param size number of processes
*/
void initialize_parallel(const char *fname, unsigned const int k, int rank, int size) {
    int seed = time(NULL);
    // int seed = 42;  // for testing purposes
    srand(seed);
    unsigned int std_chunk, chunk;
    std_chunk = (k*k)/size;
    chunk = (rank != 0) ? std_chunk : std_chunk + (k*k)%size;
    char *world; 
    char *local_world = (char *)malloc(chunk*sizeof(char));
    #pragma omp parallel for schedule(static) shared(local_world, chunk)
        for (unsigned long i = 0; i < chunk; i++)
            local_world[i] = rand() % 100 < 15 ? 255 : 0;
    if (rank == 0)
        world = (char *)malloc(k*k*sizeof(char));
    MPI_Barrier(MPI_COMM_WORLD);
    // needed because the read_pbn requires a pointer to an int
    MPI_Gather(local_world, chunk, MPI_CHAR, world, chunk, MPI_CHAR, 0, MPI_COMM_WORLD);
    if (rank == 0)
        write_pbm(world, 255, k, k, fname);
    free(local_world);
    if (rank == 0)
        free(world);
    return;
}