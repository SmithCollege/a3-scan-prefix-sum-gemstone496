#include <stdio.h>
#include <stdlib.h>

#define SIZE 512
#define BLOCK_SIZE 64

// function to calculate the scan on GPU
__global__ void scan(int *in, int *out){
  int gindex = threadIdx.x + blockIdx.x*blockDim.x;
  int end = gindex < SIZE ? gindex+1 : SIZE;
  
  int sum = 0;
  for (int i = 0; i < end; i++) {
    sum += in[i];
  }

  out[gindex] = sum;
}

int main() {
  // allocate input and output arrays
  int *in; cudaMallocManaged(&in, SIZE*sizeof(int)); //these belong on the same lines bc they're var assignment:
  int *out; cudaMallocManaged(&out, SIZE*sizeof(int)); //on a technicality, the statements must be separated.
  
  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    in[i] = 1;
  }

  // do the scan
  scan<<< (SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE , BLOCK_SIZE >>>(in, out);
  cudaDeviceSynchronize(); // patience, girls

  // check results
  for (int i = 0; i < SIZE; i++) {
    int ans = i+1;
    out[i] == ans ? printf("%d ", out[i]) : printf("\n  IDX: %d   OUT: %d   EXP: %d\n", i, out[i], ans);
  }
  printf("\n");

  // free mem
  cudaFree(in);
  cudaFree(out);

  return 0;
}
