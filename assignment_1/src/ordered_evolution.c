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
* Performs the ordered evolution method and saves the result to a file.
* - ordered evolution: the state of each cell is updated before moving to the next cell.
* @param fname name of the file that's going to be written to store the initial game field
* @param k size of the game field
* @param n number of iterations
* @param s every how many iterations save a snapshot
*/
void run_ordered(const char *fname, unsigned int k, unsigned const int n, unsigned const int s) {
    
    // load game field initialization
    unsigned char *world; 
    world = malloc(k*k*sizeof(unsigned char));
    read_pbm((void**)&world, omaxVal, &k, &k, fname);
    for(unsigned int iter = 0; iter < n; iter++) {
        
        // check if the cells are alive or dead
        #pragma omp parallel for schedule(static)
        for (unsigned long i = 0; i < k*k; i++)
            world[i] = should_live(k, i, world, omaxVal);
        
        // check if it's time to take a snapshot
        if (s==0) {
            continue;
        }            

        if (iter%s == 0) {
            char *snapname = malloc(31*sizeof(char));
            sprintf(snapname, "snaps/snapshot_%06d.pbm", iter); 
            write_pbm((void*)world, omval, k, k, snapname);
            free(snapname);
        }
    }

    // save final snapshot
    char *filename = malloc (21*sizeof(char));
    sprintf(filename, "game_of_life_END.pbm");
    write_pbm((void*)world, omval, k, k, filename);
    free(filename);
    free(world);
    return;
}
