#include "cuda_runtime.h"
#include <iostream>
using namespace std;

__global__ void add(int *d_a,int *d_b,int *d_c){
	*d_c = *d_a + *d_b;
}

int main(void){
	int a, b, c;
	int *d_c, *d_b, *d_a;
	int size = sizeof(int);

	a = 4; 
	b = 6;
	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);
	cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);
	add<<<1,1>>>(d_a, d_b, d_c);
	cudaMemcpy(&c, d_c, size, cudaMemcpyDeviceToHost);
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	cout << c << endl;
	return 0;
}
