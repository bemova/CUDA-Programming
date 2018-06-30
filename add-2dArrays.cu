#include <iostream>
#include <cuda_runtime.h>

using namespace std;
#define N 20
#define BLOCK_DIM 10

void random_inits(int a[N][N]){
	for (int i = 0; i < N; i++){
		for (int j = 0; j < N; j++){
			a[i][j] = rand() % 10;
		}
	}
}

__global__ void add(int a[N][N], int b[N][N], int c[N][N]){
	int i = threadIdx.x;
	int j = threadIdx.y;
	c[i][j] = a[i][j] + b[i][j];
}


void show(int a[N][N], int b[N][N], int c[N][N]){
	for (int i = 0; i < N; i++){
		for (int j = 0; j < N; j++){
			cout << "matrix[" << i << "][" << j << "]" << " = " << a[i][j] << " + " << b[i][j] << "=" << c[i][j] <<"\t";
		}
		cout << endl;
	}
}

int main(void){
	int a[N][N];
	int b[N][N];
	int c[N][N];
	random_inits(a);
	random_inits(b);

	int (*d_a)[N], (*d_b)[N], (*d_c)[N];

	cudaMalloc((void**)&d_a, (N*N)*sizeof(int));
	cudaMalloc((void**)&d_b, (N*N)*sizeof(int));
	cudaMalloc((void**)&d_c, (N*N)*sizeof(int));

	cudaMemcpy(d_a, a, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, c, (N*N)*sizeof(int), cudaMemcpyHostToDevice);

	int numBlocks = 1;
	dim3 threadsPerBlock(N,N);
	add<<<numBlocks,threadsPerBlock>>>(d_a,d_b,d_c);

	cudaMemcpy(c, d_c, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);

	show(a, b, c);

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	cout<< endl;

	return 0;
}
