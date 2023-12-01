/*
    This code is a modified version of the code given
    by the professor in the assignment description.
    Original code can be found here:
    https://github.com/Foundations-of-HPC/Foundations_of_HPC_2022/blob/main/Assignment/exercise1/read_write_pgm_image.c 
*/

#include <stdlib.h>
#include <stdio.h> 

#include<mpi.h>

#include "read_write.h"

#define XWIDTH 256
#define YWIDTH 256
#define MAXVAL 65535


/*
    write_pbm():    writes a pbm image to a file.
        it prints also an header, that is structured as follows:
        - the magic number (see below)
        - the image's width
        - the image's height
        - a whitespace
        - the maximum color value, which must be between 0 and 65535

        magic number: 

            TYPE    MAGIC NUM     EXTENSION   COLOR RANGE
                ASCII  BINARY
            PBM   P1     P4       .pbm        [0-1]
            PGM   P2     P5       .pgm        [0-255]
            PPM   P3     P6       .ppm        [0-2^16[
  
    @param
    image:      a pointer to the memory region that contains the image
                that should be rappresented by a char array.
    maxval:     either 255 or 65536 (in case of a 16 bit image)
    xsize:      x dimension of the image
    ysize:      y dimension of the image
    image_name: the name of the file to be written
 */


void write_pbm(const void *image, const unsigned int maxval, const unsigned int xsize,
               const unsigned int ysize, const char *image_name)
{
  FILE* image_file; 
  image_file = fopen(image_name, "w"); 
  int color_depth = 1 + ( maxval > 255 );
  fprintf(image_file, "%d %d\n%d\n", xsize, ysize, maxval);
  fwrite( image, 1, xsize*ysize*color_depth, image_file);  
  fclose(image_file); 
  return ;

}



/*
    read_pbn(): reads a pbm image from a file and save it into a char array given.
    @param
    image:      a pointer to the pointer that rappresent the memory region
                which will contain the image.
    maxval:     a pointer to the int that stores the maximum intensity in the image
                (either 255 or 65536)
    xsize:      a pointer to the x dimension of the image
    ysize:      a pointer to the y dimension of the image
    image_name: the name of the file to be read 
*/

void read_pbm(void **image, unsigned int *maxval, unsigned int *xsize, unsigned int *ysize, const char *image_name)
{
    FILE* image_file; 

    char    MagicN[2];
    char   *line = NULL;
    size_t  k, n = 0;
    *image = NULL;
    *xsize = *ysize = *maxval = 0;

    image_file = fopen(image_name, "r"); 

    k = fscanf(image_file, "%2s%*c", MagicN );  // get the Magic Number
    k = getline( &line, &n, image_file);        // skip all the comments

    while ( (k > 0) && (line[0]=='#') )
        k = getline( &line, &n, image_file);
    if (k > 0)
    {
        k = sscanf(line, "%d%*c%d%*c%d%*c", xsize, ysize, maxval);
        if ( k < 3 )
	        fscanf(image_file, "%d%*c", maxval);
    }
    else    
    {
      *maxval = -1; // this is the signal that there was an I/O error while reading the image header
      free( line );
      return;
    }

    free( line );
    int color_depth = 1 + ( *maxval > 255 );
    unsigned int size = *xsize * *ysize * color_depth;
  
    if ( (*image = (char*)malloc( size )) == NULL )
    {
        fclose(image_file);
        *maxval = -2;         // this is the signal that memory was insufficient
        *xsize  = 0;
        *ysize  = 0;
        return;
    }
    if ( fread( *image, 1, size, image_file) != size )
    {
        free( image );
        image   = NULL;
        *maxval = -3;         // this is the signal that there was an i/o error
        *xsize  = 0;
        *ysize  = 0;
    }  
  fclose(image_file);
  return;
} // void read_pbm()
