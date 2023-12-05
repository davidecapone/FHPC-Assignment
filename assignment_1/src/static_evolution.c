/**
* @file static_evolution.c
* @brief This file contains the functions needed to perform the static evolution
* @details 
**/

#include<stdio.h>
#include<stdlib.h>
#include<omp.h>
#include<time.h>
#include<mpi.h>
#include"static_evolution.h"
#include"check_cell_state.h"
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

unsigned int smval;                   
unsigned int *smaxVal = &smval;

/**
* Performs the static evolution method and saves the result to a file.
* - static evolution: the game field is freezed and the next state for 
*   each cell is computed, the update of the whole game field is done 
*   at the end of the computation.
* @param fname name of the file that's going to be written to store the initial game field
* @param k size of the game field
* @param n number of iterations
* @param s every how many iterations save a snapshot
* @param rank rank of the process
* @param size number of processes
*/
void run_static(const char *fname, unsigned int k, unsigned const int n, unsigned int s, int rank, int size) {
    if (size > 1) { // more processes: parallel  
        double start = CPU_TIME;
        parallel_static(fname, k, n, s, rank, size);
        double end = CPU_TIME;
        if (rank == 0)
            printf(",%f\n", end-start); // only the master process prints the execution time
        MPI_Finalize();
        return;
    } else { // single process: serial
        double start = CPU_TIME;
        MPI_Finalize();
        serial_static(fname, k, n, s);
        double end = CPU_TIME;
        printf(",%f\n", end-start);
        return;
    }
}

/**
* Performs the static evolution of the playground, in parallel, and saves the result to a file.
* @param fname name of the file that's going to be written to store the initial game field
* @param k size of the game field
* @param n number of iterations
* @param s every how many iterations save a snapshot
* @param rank rank of the process
* @param size number of processes
*/
void parallel_static(const char *fname, unsigned int k, unsigned const int n, unsigned int s, int rank, int size) {
    
    // Each process reads the initial game field 
    unsigned char *world;
    world =malloc(k*k*sizeof(unsigned char));
    read_pbm((void **)&world, smaxVal, &k, &k, fname); 

    // chunk_size:  size of the chunk (portion of game field) computed by each process
    // offset:      offset of the chunk w.r.t. the game field
    unsigned long chunk_size = k*k/size;
    if (chunk_size*size < k*k && rank < k*k-chunk_size*size) chunk_size++;                                        
    
    unsigned int *offset = malloc(size*sizeof(unsigned long));
    unsigned int *lengths = malloc(size*sizeof(unsigned int));

    for (unsigned long i = 0; i < size; i++) {                               
        lengths[i] = k*k/size;
        if (lengths[i]*size < k*k && i < k*k-lengths[i]*size)
            lengths[i]++;
        offset[i] = i == 0 ? 0 : offset[i-1]+lengths[i-1]; 
    }

    unsigned char *my_partial_result = malloc(lengths[rank]*sizeof(unsigned char));
    for (unsigned int iter = 0; iter < n; iter++) {

        MPI_Barrier(MPI_COMM_WORLD);

        // Each process computes the evolution of its chunk, then sends the result to all the other processes
        #pragma omp parallel for schedule(static)
        for (unsigned long i = 0; i < lengths[rank]; i++)
            my_partial_result[i] = check_cell_state(k, i+offset[rank], world, smaxVal);

        MPI_Allgatherv((void *)my_partial_result, lengths[rank], MPI_UNSIGNED_CHAR, (void *)world, (int *)lengths, (int *)offset, MPI_UNSIGNED_CHAR, MPI_COMM_WORLD);

        // check if it's time to take a snapshot
        if (rank == 0) { // i.e. master process
            if ((s!=0) && ( iter%s == 0)) {
                char *snapname = malloc(31*sizeof(char));
                sprintf(snapname, "snaps/snapshot_%06d.pbm", iter);
                write_pbm((void*)world, smval, k, k, snapname);
                free(snapname);
            }
        }
    }

    if (rank == 0) { // i.e. master process
        char *filename = malloc (21*sizeof(char));
        sprintf(filename, "game_of_life_END.pbm");
        write_pbm((void*)world, smval, k, k, filename);
        free(filename);
    }
    free(world);
    free(my_partial_result);
    free(offset);
    free(lengths);
    return; 
}

/**
* Performs the static evolution of the playground and saves the result to a file, in serial.
* @param fname name of the file that's going to be written to store the initial game field
* @param k size of the game field
* @param n number of iterations
* @param s every how many iterations save a snapshot
*/
void serial_static(const char *fname, unsigned int k, unsigned const int n, unsigned int s) {
    
    // read the initial state of the playground from the file
    unsigned char *prev_state; 
    unsigned char *curr_state;
    prev_state = malloc(k*k*sizeof(char));
    read_pbm((void**)&prev_state, smaxVal, &k, &k, fname);
    
    for (unsigned int iter = 0; iter < n; iter++) {
        curr_state = malloc(k*k*sizeof(char));

        // check if the cells should be alive or dead
        #pragma omp parallel for schedule(static)
        for (unsigned long i = 0; i < k*k; i++)
            curr_state[i] = check_cell_state(k, i, prev_state, smaxVal);
        unsigned char *tmp = prev_state;
        prev_state = curr_state;
        curr_state = tmp;
        free(curr_state);

        // check if it's time to save a snapshot of the playground
        if (s==0) {
            continue;
        }

        if (iter%s == 0) {
            char *snapname = malloc(31*sizeof(char));
            sprintf(snapname, "snaps/snapshot_%06d.pbm", iter);
            write_pbm((void*)prev_state, smval, k, k, snapname);
            free(snapname);
        }
        
    }

    // save the final snapshot
    char *filename = malloc (21*sizeof(char));
    sprintf(filename, "game_of_life_END.pbm");
    write_pbm((void*)prev_state, smval, k, k, filename);
    free(filename);
    free(prev_state);
    return;
}