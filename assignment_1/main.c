/**
* @file main.c
* @brief main file for Conway's game of life
* @details this is a slightly modified version of the code provided by the professor, original code:
*   https://github.com/Foundations-of-HPC/Foundations_of_HPC_2022/blob/main/Assignment/exercise1/get_args.c
**/
#include<stdio.h>
#include<stdlib.h>
#include<getopt.h> 
#include<omp.h>
#include<mpi.h>
#include "initialize.h"
#include "run.h"

#define INITIALIZE 1                    // for -i: initialize
#define RUN 2                           // for -r : run
#define ORDERED 0                       // for -e : ordered or static evolution
#define STATIC 1
#define K_DEFAULT 100                   // for -k : game field size
#define N_DEFAULT 10                    // for -n : number of iterations
#define S_DEFAULT 0                     // for -s : step to save a snapshot
#define F_DEFAULT "game_of_life.pbm"    // for -f : initial game field file name

char action, e; 
unsigned int k = K_DEFAULT;
unsigned int n = N_DEFAULT;
unsigned int s = S_DEFAULT;
char *fname = NULL;

int main(int argc, char *argv[]) {
    char* optstring = "irk:e:f:n:s:";    
    int c; 

    while ((c = getopt(argc, argv, optstring)) != -1) {
        switch (c) {
            case 'i':
                action = INITIALIZE;
                break;
            case 'r':
                action = RUN;
                break;
            case 'k':
                k = atoi(optarg);
                break;
            case 'e':
                e = atoi(optarg);
                break;
            case 'f':
                fname = (char*)malloc(25*sizeof(char));
                sprintf(fname, "%s", optarg);
                break;
            case 'n':
                n = atoi(optarg);
                break;
            case 's':
                s = atoi(optarg);
                break;
            default :
                printf("argument -%c not known\n", c );
                break;  
        }
    }

    if (action != INITIALIZE && action != RUN) {
        printf("To run the program, the user must specify either -i or -r  option\n");
        return 0;
    }

    if (fname == NULL) {
        fname = (char*)malloc( sizeof(char)*17 );     
        sprintf(fname, "%s", F_DEFAULT);
    }

    if (e != ORDERED && e != STATIC) {
        printf("The user must specify either -e 0 or -e 1\n");
        printf("-e 0 means ordered evolution, -e 1 means static evolution\n");
        return 0;
    }

    if (action == INITIALIZE) initialize(fname, k);
    if (action == RUN) run(fname, k, n, s, e);
    free(fname);

    return 0;
}