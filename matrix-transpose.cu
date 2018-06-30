#include <iostream>
#include <cuda_runtime.h>
#include <vector>

using namespace std;

#define M 3
#define N 2
#define BLOCK_SIZE 16

void initialize_matrix(int* matrix, int row, int col){
	for (int i = 0; i < row; ++i) {
		for (int j = 0; j < col; ++j) {
			matrix[i * col + j] = rand() % 10;
			cout << matrix[i * col + j] << "\t";
		}
	}
}

__global__ void transpose(int* input, int* output, int row, int col)
{
	unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx < col && idy < row)
	{
		int pos = idy * col + idx;
		int trans_pos = idx * row + idy;
		output[trans_pos] = input[pos];
	}
}


int main(void) {
	int *a, *b;
	int first_size = sizeof(int) * M * N;
	int second_size = sizeof(int) * N * M;

	a = (int *)malloc(first_size);
	b = (int *)malloc(second_size);

	initialize_matrix(a, M, N);
	cout << endl;


	int *d_a, *d_b;
	cudaMalloc((void **)&d_a, first_size);
	cudaMalloc((void **)&d_b, second_size);

	cudaMemcpy(d_a, a, first_size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, second_size, cudaMemcpyHostToDevice);

	unsigned int grid_rows = (M + BLOCK_SIZE - 1) / BLOCK_SIZE;
	unsigned int grid_cols = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
	dim3 dimGrid(grid_cols, grid_rows);
	dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

	transpose << <dimGrid, dimBlock >> >(d_a, d_b, M, N);
	cudaMemcpy(b, d_b, second_size, cudaMemcpyDeviceToHost);

	for (int i = 0; i < N * M; i++) {
		cout << b[i] << endl;
	}

	cudaFree(d_a);
	cudaFree(d_b);

	return 0;
}

