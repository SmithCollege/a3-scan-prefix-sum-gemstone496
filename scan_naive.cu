#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <iostream>

#define SIZE 2048
#define BLOCK_SIZE 128
#define RUNS 100

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

  for (int i = 0; i < RUNS; i++) {
    const auto start{std::chrono::steady_clock::now()};
    scan<<< (SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE , BLOCK_SIZE >>>(in, out);
    cudaDeviceSynchronize(); // patience, girls
    const auto end{std::chrono::steady_clock::now()};
    const std::chrono::duration<double> elapsed{end - start};
    std::cout << elapsed.count() << "\n";
  }

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
