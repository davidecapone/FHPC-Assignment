/**
* @file ordered_evolution.c
* @brief This file contains the functions needed to perform the ordered evolution
* @details 
**/

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<omp.h>
#include<mpi.h>
#include"ordered_evolution.h"
#include"should_live.h"
#include"read_write.h"

unsigned int omval;                   
unsigned int *omaxVal = &omval;

/**
* Performs the ordered evolution of the playground and saves the result to a file.
* - ordered evolution means that the evolution of the playground is computed 
*   evaluating the next state of a cell and updating it before 
*   moving to the next cell.
* - the ordered evolution can be performed only in serial for the point of view of MPI.
* @param fname name of the file containing the initial state of the playground
* @param k size of the squre matrix that's going to rapresent the playground
* @param n number of generations must be computed
* @param s every how many generations save a snapshot
* @param rank rank of the process
* @param size number of processes
*/
void run_ordered(const char *fname, unsigned int k, unsigned const int n, unsigned const int s) {
    
    // read the initial state of the playground from the file
    unsigned char *world; 
    world = malloc(k*k*sizeof(char));
    read_pbm((void**)&world, omaxVal, &k, &k, fname);
    for(unsigned int day = 0; day < n; day++)
    {
        
        // compute the evolution of the playground and 
        // decide if a cell should alive or dead
        #pragma omp parallel for schedule(static)
        for (unsigned long i = 0; i < k*k; i++)
            world[i] = should_live(k, i, world, omaxVal);
        
        // check if it's time to save a snapshot of the playground
        if (s==0)
            continue;

        if (day%s == 0) {
            // save a snapshot of the playground
            char *snapname = malloc(31*sizeof(char)); // 31 = length of "snaps/snapshot_%06d.pbm"
            sprintf(snapname, "snaps/snapshot_%06d.pbm", day); 
            write_pbm((void*)world, omval, k, k, snapname);
            free(snapname);
        }
    }

    char *filename = malloc (21*sizeof(char));
    sprintf(filename, "game_of_life_END.pbm");
    write_pbm((void*)world, omval, k, k, filename);
    free(filename);
    free(world);
    return;
}
