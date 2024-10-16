#include <stdio.h>
#include <stdlib.h>

#define SIZE 128

int main() {
  // allocate memory
  int* input = (int*) (malloc(sizeof(int) * SIZE));
  int* output = (int*) (malloc(sizeof(int) * SIZE));

  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    input[i] = 1;
   }

  // do the scan
  for (int i = 0; i < SIZE; i++) {
   int value = 0;
   for (int j = 0; j <= i; j++) {
     value += input[j];
   }
    output[i] = value;
  }

  // check results
  for (int i = 0; i < SIZE; i++) {
    int ans = (i+1)*(i+2) / 2;
    output[i] == ans ? printf("%d ", output[i]) : printf("\n  IDX: %d   OUT: %d\n", i, output[i]);
  }
  printf("\n");

  // free mem
  free(input);
  free(output);

  return 0;
}
