# Assignment 1

A parallel implementation of the Conway's Game of Life using the C programming language, with a hybridization of the MPI and OpenMP libraries, following the requirements given in the [assignment instructions](https://github.com/Foundations-of-HPC/Foundations_of_HPC_2022/blob/main/Assignment/exercise1/Assignment_exercise1.pdf) file, follows a scalability test on the Orfeo cluster.

## Content of this directory
- [`main.c`](main.c): the file that is used to run the program with the corresponding arguments;
- [`MakeFile`](/assignment_1/Makefile): the file that is used to compile the code;
- [`plots.ipynb`](plots.ipynb): the python code used to create the plots for the final report and analyze them;
- [`assets/`](/assignment_1/assets/): the folder that contains all the graph images for the final report;
- [`include/`](/assignment_1/include/): the folder that contains the header files;
- [`obj/`](/assignment_1/obj/): the folder that contains the object files, created during the compilation;
- [`results/`](/assignment_1/results/): the folder that conatins the results for the scalabililty test in csv format.
- [`slurm-scripts/`](/assignment_1/slurm-scripts/): the folder that contains the following slurm scripts:
  - [`omp_scalability.sh`](/assignment_1/slurm-scripts/omp_scalability.sh): the bash file used to run the OpenMP scalability tests;
  - [`run.sh`](/assignment_1/slurm-scripts/run.sh): the bash file used to run the correctness tests;
  - [`strong_mpi_scalability.sh`](/assignment_1/slurm-scripts/strong_mpi_scalability.sh): the bash file used to run the strong MPI scalability tests;
- [`slurm.out/`](/assignment_1/slurm.out/): the folder that contains the slurm jobs output;
- [`snaps/`](/assignment_1/snaps/): the folder that contains the snapshots of the game;
- [`src/`](/assignment_1/src/): the folder that conatins all the functions that are needed to run the program.

## How to compile the code
The compilation of the code is done by calling `Makefile` with the `make` command. 

#### Compiling on the Orfeo cluster

To compile the code on the Orfeo cluster, first of all, the module which contains the `Open MPI` library and the GNU compiler has to be loaded. 

```bash
module load openMPI/4.1.5/gnu/12.2.1
srun -N1 -p EPYC make
```
The `main.x` executable is then created in the current directory.

The `Makefile` can also accept the following options:

- `make clean`: removes the `main.x` executable and all the `.o` object files in the `obj/` directory.
- `make clean_images`: deletes all the `.pbm` files in the current directory and in the `snaps/` directory. 

## How to run the code

To run the code, three options are available:
-   ```bash
    sbatch slurm-scripts/run.sh
    ```
    to test the correctness of the Game of Life implementation;
-   ```bash
    sbatch slurm-scripts/omp_scalability.sh
    ```
    to perform a scalability test for OpenMP;
-   ```bash
    sbatch slurm-scripts/strong_mpi_scalability.sh
    ```
    to perform a strong MPI scalability test.


The `main.x` executable can be runned with the following arguments:

| Argument | Description                                                                                                                                                                                                                                                                                                                                               |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -i       | This flag is used to initialize the game on a k × k field, with random values, which is then saved on a file.                                                                                                            |
| -r       | This flag is used to load the initial configuration and run the game from there.                                                                             |
| -k       | This flag is used to specify the size of the game field (default: 100).                                                                                                                                                  |
| -e       | This flag is used to specify the evolution type, two options are possible: -0: with the ordered evolution method, the cells will be updated sequentially following row-major order -1: with the static evolution method, the next state will be computed for all the cells at once, and only at the end of each iteration the update will be carried out. |
| -f       | This flag is used to specify the name of the initial file: if it is used in combination with the -i file, it will specify the name of the file where the random initialization is saved, otherwise (with the -r flag) it will specify the file where the initial configuration has to be retrieved (default: game_of_life.pbm).                           |
| -n       | This flag is used to specify the number of iterations (default: 10).                                                                                   |
| -s       | This flag is used to specify the frequency at which the snapshots of the game field will be taken, the value 0 means that only the final step will be dumped as a snapshot (default: 0).                                                                                                                        