#!/bin/bash

#Sequencial
#gcc bfSequencial.c -o bfseq -std=c99 -O3
#./bfseq "$1"

#OMP
gcc omp-bf.c -o bfomp -fopenmp -lm -std=c99 -O3

#CUDA
nvcc cuda-bf.cu -o bfcuda

if [[  -f "speedup.dat" ]]; then
rm -rf speedup.dat
fi

if [[  -f "speedup_cuda.dat" ]]; then
rm -rf speedup_cuda.dat
fi

for((i = 2; i <= 128; i*=2))
do
    echo OMP "$i"
    OMP_NUM_THREADS=$i ./bfomp "$1"
done

for((i = 2; i <= 1024; i*=2))
do
    echo CUDA "$i"
    ./bfcuda "$1" "$i"
done
