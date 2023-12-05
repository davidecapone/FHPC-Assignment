/**
* Checks if a cell should live or die.
* @param k size of the game field
* @param i index of the cell to check
* @param world pointer to the game field
* @param maxVal pointer to the maximum value of the game field
* @return &maxVal if the cell should live, 0 otherwise
*/
unsigned char check_cell_state(unsigned const int k,  unsigned const long i, unsigned const char *world, unsigned const int *maxVal) {
    int result = 0;   // char is not enough to store the first sum
    register unsigned const int row = i/k;
    register unsigned const int col = i%k;
    result  = world[((row - 1 + k) % k) * k + ((col - 1 + k) % k)]  // top left
            + world[((row - 1 + k) % k) * k + col]                  // top middle
            + world[((row - 1 + k) % k) * k + ((col + 1) % k)]      // top right
            + world[row * k + ((col - 1 + k) % k)]                  // middle left
            + world[row * k + ((col + 1) % k)]                      // middle right
            + world[((row + 1) % k) * k + ((col - 1 + k) % k)]      // bottom left
            + world[((row + 1) % k) * k + col]                      // bottom middle
            + world[((row + 1) % k) * k + ((col + 1) % k)];         // bottom right
    result /= (*maxVal);
    result = ((result == 2) || (result == 3)) ? *maxVal : 0;
    return (unsigned char)result;
}