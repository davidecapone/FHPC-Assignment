# Assignment 1

In this folder you find all the files for the first assignment (the Conway's game of life).

## How to run the code
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