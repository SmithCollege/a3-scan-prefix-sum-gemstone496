#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <iostream>

#define SIZE 2048
#define BLOCK_SIZE 128
#define RANGE 16
#define RUNS 100

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

  int sumsLen = (SIZE+RANGE-1)/RANGE; // length of sums, so we don't edit oob
  ++gindex < sumsLen ? sums[gindex] += sum : sums[gindex] = 0; // it's ok it'll work i pwomise
    //printf("idx: %d   sum: %d   \n", gindex, sum);
    //for (++gindex; gindex < sumsLen; gindex++){
    //sums[gindex] += sum;
    //}
}

__global__ void scan_final(int *out, int *sums){
  int gindex = threadIdx.x + blockIdx.x*blockDim.x;
  int sindex = gindex/RANGE;

  out[gindex] += sums[sindex];
}

int main() {
  // allocate input and output arrays
  int sumsLen = (SIZE+RANGE-1)/RANGE; //ceiling of SIZE/RANGE
  int numBlocks = (SIZE + BLOCK_SIZE*RANGE - 1) / (BLOCK_SIZE*RANGE);
  int *in; cudaMallocManaged(&in, SIZE*sizeof(int)); //these belong on the same lines bc they're var assignment:
  int *out; cudaMallocManaged(&out, SIZE*sizeof(int)); //on a technicality, the statements must be separated.
  int *sums; cudaMallocManaged(&sums, sumsLen*sizeof(int));
  
  
  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    in[i] = 1;
  }
  for (int i = 0; i < sumsLen; i++) {
    sums[i] = 0;
  }

  for (int i = 0; i < RUNS; i++) {
    int cSum = 0;
    const auto start{std::chrono::steady_clock::now()};
    
    scan_range<<< numBlocks, BLOCK_SIZE >>>(in, out, sums);
    cudaDeviceSynchronize(); // patience, girls
    for (int i = 1; i < sumsLen; i++) {
      sums[i] += cSum;
      cSum = sums[i];
    }
    scan_final<<< numBlocks, BLOCK_SIZE*RANGE >>>(out, sums);
    cudaDeviceSynchronize(); // remain patient
    
    const auto end{std::chrono::steady_clock::now()};
    const std::chrono::duration<double> elapsed{end - start};
    std::cout << elapsed.count() << "\n";
  }
  
  // do the scan
  scan_range<<< numBlocks, BLOCK_SIZE >>>(in, out, sums);
  cudaDeviceSynchronize(); // patience, girls

  int cSum = 0;
  for (int i = 1; i < sumsLen; i++) {
    sums[i] += cSum;
    cSum = sums[i];
  }
  
  scan_final<<< numBlocks, BLOCK_SIZE*RANGE >>>(out, sums);
  cudaDeviceSynchronize(); // remain patient

  // check results
  for (int i = 0; i < SIZE; i++) {
    int ans = i+1;
    if (out[i] != ans) { std::cerr << "IDX: " << i << "   OUT: " << out[i] << "   EXP: " << ans << std::endl; }
  }

  // free mem
  cudaFree(in);
  cudaFree(out);

  return 0;
}
