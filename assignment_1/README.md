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
  - [`omp_scalability.sh`](/assignment_1/slurm-scripts/omp_scalability.sh): 
  - [`run.sh`](/assignment_1/slurm-scripts/run.sh):
  - [`strong_mpi_scalability.sh`](/assignment_1/slurm-scripts/strong_mpi_scalability.sh):
- [`slurm.out/`](/assignment_1/slurm.out/):
- [`snaps/`](/assignment_1/snaps/):
- [`src/`](/assignment_1/src/):





In order to run the game with your custom settings, you can modify the file `slurm-scripts/run.sh` and then easily run it with the `sbatch` command:

```
sbatch slurm-script/run.sh
```

In the `run.sh` file you choose all the arguments to pass at the `main.c` program. 
All the possible arguments are the following:

| Argument | Description                                                                                                                                                                                                                                                                                                                                               |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -i       | This flag is used to initialize the game on a k × k field, with random values, which is then saved on a file.                                                                                                            |
| -r       | This flag is used to load the initial configuration and run the game from there.                                                                             |
| -k       | This flag is used to specify the size of the game field (default: 100).                                                                                                                                                  |
| -e       | This flag is used to specify the evolution type, two options are possible: -0: with the ordered evolution method, the cells will be updated sequentially following row-major order -1: with the static evolution method, the next state will be computed for all the cells at once, and only at the end of each iteration the update will be carried out. |
| -f       | This flag is used to specify the name of the initial file: if it is used in combination with the -i file, it will specify the name of the file where the random initialization is saved, otherwise (with the -r flag) it will specify the file where the initial configuration has to be retrieved (default: game_of_life.pbm).                           |
| -n       | This flag is used to specify the number of iterations (default: 10).                                                                                   |
| -s       | This flag is used to specify the frequency at which the snapshots of the game field will be taken, the value 0 means that only the final step will be dumped as a snapshot (default: 0).                                                                                                                         
## Content of this directory

- [main.c](main.c)
- [MakeFile](Makefile)
- [slurm-scripts](slurm-scripts)
- [src/](src)
- [obj/](obj)
- [include/](include)
- [snaps/](snaps)
- [results/](results)