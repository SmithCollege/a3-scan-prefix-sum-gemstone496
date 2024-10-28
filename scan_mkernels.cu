#include <stdio.h>
#include <stdlib.h>

#define SIZE 512
#define BLOCK_SIZE 64
#define RANGE 4

// function to calculate the scan on GPU
__global__ void scan_range(int *in, int *out, int *sums){
  int gindex = threadIdx.x + blockIdx.x*blockDim.x;
  int start = gindex*RANGE;
  int end = start+RANGE < SIZE ? start+RANGE : SIZE;
  
  int sum = 0;
  for (int i = start; i < end; i++) {
    sum += in[i];
    out[i] = sum;
  }

  int sumsLen = (SIZE+RANGE-1)/RANGE; // add in appropriate sums
  for (int i = gindex+1; i < sumsLen; i++){
    sums[gindex] += sum;
  }
}

__global__ void scan_final(int *out, int *sums){
  int gindex = threadIdx.x + blockIdx.x*blockDim.x;
  int sindex = gindex/RANGE;

  out[gindex] += sums[sindex];
}

int main() {
  // allocate input and output arrays
  int *in; cudaMallocManaged(&in, SIZE*sizeof(int)); //these belong on the same lines bc they're var assignment:
  int *out; cudaMallocManaged(&out, SIZE*sizeof(int)); //on a technicality, the statements must be separated.
  int *sums; cudaMallocManaged(&sums, (SIZE+RANGE-1)/RANGE *sizeof(int)); //ceiling of SIZE/RANGE
  
  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    in[i] = 1;
  }
  for (int i = 0; i < (SIZE+RANGE-1)/RANGE; i++) {
    sums[i] = 0;
  }

  // do the scan
  int numBlocks = (SIZE + BLOCK_SIZE*RANGE - 1) / (BLOCK_SIZE*RANGE);
  scan_range<<< numBlocks, BLOCK_SIZE >>>(in, out, sums);
  cudaDeviceSynchronize(); // patience, girls
  scan_final<<< numBlocks, BLOCK_SIZE*RANGE >>>(out, sums);
  cudaDeviceSynchronize(); // remain patient

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
