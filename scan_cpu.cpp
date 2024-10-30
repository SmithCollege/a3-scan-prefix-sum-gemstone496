#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <iostream>

#define SIZE 2048
#define RUNS 100

int main() {
  // allocate memory
  int* input = (int*) (malloc(sizeof(int) * SIZE));
  int* output = (int*) (malloc(sizeof(int) * SIZE));

  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    input[i] = 1;
  }

  for (int i = 0; i < RUNS; i++) {
    const auto start{std::chrono::steady_clock::now()};

    // do the scan
    int value = 0;
    for (int i = 0; i < SIZE; i++) {
      value += input[i];
      output[i] = value;
    }
    
    const auto end{std::chrono::steady_clock::now()};
    const std::chrono::duration<double> elapsed{end - start};
    std::cout << elapsed.count() << "\n";
  }

  // check results
  for (int i = 0; i < SIZE; i++) {
    int ans = i+1;
    if (output[i] != ans) { std::cerr << "IDX: " << i << "   OUT: " << output[i] << "   EXP: " << ans << std::endl; }
  }

  // free mem
  free(input);
  free(output);

  return 0;
}
