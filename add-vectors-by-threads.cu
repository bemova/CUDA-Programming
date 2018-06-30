#include <iostream>
#include <cuda_runtime.h>
using namespace std;

#define N 10

void random_ints(int *a, int n){
	for (int i = 0; i < n; i++){
		a[i] = rand() % 10;
	}
}

__global__ void add(int *a, int *b, int *c){
	c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x];
}

int main(void){
	int *a, *b, *c;
	int *d_a, *d_b, *d_c;
	int size = N * sizeof(int);
	a = (int *)malloc(size); random_ints(a, N);
	b = (int *)malloc(size); random_ints(b, N);
	c = (int *)malloc(size); 

	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);

	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

	add << <1, N >> > (d_a, d_b, d_c);
	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
	for (int i = 0; i < N; i++){
		cout << a[i] << " + " << b[i] << " = " << c[i] << endl;
	}
	free(a); free(b); free(c);
	cudaFree(a); cudaFree(b); cudaFree(c);

}
