#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <cuda.h>
// 97 to 122 use only lowercase letters
// 65 to 90 use only capital letters
// 48 to 57 use only numbers

#define START_CHAR 48
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20

__device__ __host__ long long my_pow(long long x, int y)
{
    long long res = 1;
    if (y == 0)
        return res;
    else
        return x * my_pow(x, y - 1);
}

__device__ int my_strlen(char *s)
{
    int len = 0;
    while (s[len] != '\0')
    {
        len = len + 1;
    }
    return (len);
}

__global__ void bruteForce(char *pass)
{

    int pass_b26[MAXIMUM_PASSWORD];

    long long int j = blockIdx.x * blockDim.x + threadIdx.x;
    long long int pass_decimal = 0;
    int base = END_CHAR - START_CHAR + 2;
    int size = my_strlen(pass);
    for (int i = 0; i < size; i++)
        pass_b26[i] = (int)pass[i] - START_CHAR + 1;

    for (int i = size - 1; i > -1; i--)
        pass_decimal += (long long int)pass_b26[i] * my_pow(base, i);

    long long int max = my_pow(base, size);
    char s[MAXIMUM_PASSWORD];

    for (; j < max; j += blockDim.x * gridDim.x)
    {
        if (j == pass_decimal)
        {
            printf("Found password!\n");
            int index = 0;

            printf("Password in decimal base: %lli\n", j);
            while (j > 0)
            {
                s[index++] = START_CHAR + j % base - 1;
                j /= base;
            }
            s[index] = '\0';
            printf("Found password: %s\n", s);
            break;
        }
    }
}

int main(int argc, char **argv)
{
    char password[MAXIMUM_PASSWORD], *pass_d;

    strcpy(password, argv[1]);
    time_t t1, t2;
    double dif, x, speedup;
    cudaMalloc(&pass_d, sizeof(char) * MAXIMUM_PASSWORD);
    cudaMemcpy(pass_d, password, sizeof(char) * MAXIMUM_PASSWORD, cudaMemcpyHostToDevice);

    int deviceId, numberOfSMs;
    cudaGetDevice(&deviceId);
    cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
    int number_of_blocks = numberOfSMs * 32;
    int threads_per_block = atoi(argv[2]);

    time(&t1);
    printf("Try to broke the password: %s\n", password);
    bruteForce<<<number_of_blocks, threads_per_block>>>(pass_d);
    cudaDeviceSynchronize();
    time(&t2);

    dif = difftime(t2, t1);
    FILE *fptr;
    FILE *fptr1;
    char c[1000];

    if ((fptr1 = fopen("firstValue.dat", "r")) != NULL)
    {
        fscanf(fptr1, "%[^\n]", c);
        x = atof(c);

        speedup = x / dif;

        fclose(fptr1);
    }

    if ((fptr = fopen("speedupCUDA.dat", "a+")) != NULL)
    {
        fprintf(fptr, "%d\t%1.2f\n", threads_per_block, speedup);
        fclose(fptr);
    }
    else
    {
        fopen("speedupCUDA.dat", "w+");
        fprintf(fptr, "%d\t%1.2f\n", threads_per_block, speedup);
        fclose(fptr);
    }
    printf("\n%1.2f seconds\n", dif);
    return 0;
}