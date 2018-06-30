#include <iostream>
#include <cuda_runtime.h>
#include <vector>

using namespace std;

#define N 3
#define M 3
#define K 3
#define BLOCK_SIZE 16

void initialize_matrix(int* matrix, int row, int col){
	for (int i = 0; i < row; ++i) {
		for (int j = 0; j < col; ++j) {
			matrix[i * col + j] = rand() % 10;
			cout << matrix[i * col + j] << "\t";
		}
	}
}

__global__ void mul(int *a, int *b, int *c, int m, int n, int k)
{
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int sum = 0;
	if (col < k && row < m)
	{
		for (int i = 0; i < n; i++)
		{
			sum += a[row * n + i] * b[i * k + col];
		}
		c[row * k + col] = sum;
	}
}

int main(void) {
	int *a, *b, *c;
	int first_size = sizeof(int) * M * N;
	int second_size = sizeof(int) * N * K;
	int third_size = sizeof(int) * M * K;

	a = (int *)malloc(first_size);
	b = (int *)malloc(second_size);
	c = (int *)malloc(third_size);
	
	initialize_matrix(a, M, N);
	cout << endl;

	initialize_matrix(b, N, K);
	cout << endl;

	int *d_a, *d_b, *d_c;
	cudaMalloc((void **)&d_a, first_size);
	cudaMalloc((void **)&d_b, second_size);
	cudaMalloc((void **)&d_c, third_size);

	cudaMemcpy(d_a, a, first_size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, second_size, cudaMemcpyHostToDevice);

	unsigned int grid_rows = (M + BLOCK_SIZE - 1) / BLOCK_SIZE;
	unsigned int grid_cols = (K + BLOCK_SIZE - 1) / BLOCK_SIZE;
	dim3 dimGrid(grid_cols, grid_rows);
	dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

	mul << <dimGrid, dimBlock >> >(d_a, d_b, d_c, M, N, K);
	cudaMemcpy(c, d_c, third_size, cudaMemcpyDeviceToHost);

	for (int i = 0; i < M * K; i++) {
		cout << c[i] << endl;
	}

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	return 0;
}

