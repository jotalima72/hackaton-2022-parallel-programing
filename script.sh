#!/bin/sh
gcc sequencial-bf.c -o bfseq -std=c99 -O3
mpicc mpi-bf.c -o bfmpi -std=c99 -O3
gcc omp-bf.c -o bfomp -fopenmp -lm -std=c99 -O3
nvcc cuda-bf.cu -o bfcuda

if [[ ! -f "firstValue-$1.dat" ]]; then
  echo codigo sequencial
  ./bruteForce "$1"
fi

if [[  -f "speedupOMP-$1.dat" ]]; then
  echo achei o arquivo
rm -rf speedupOMP-$1.dat
fi


if [[  -f "speedupCUDA-$1.dat" ]]; then
rm -rf speedupCUDA-$1.dat
fi

if [[  -f "speedupMPI-$1.dat" ]]; then
  rm -rf speedupMPI-$1.dat
fi


for((i = 2; i <=64; i*=2))
do
  echo ===========================================
  echo opemMP "$i" threads
    OMP_NUM_THREADS=$i ./bfomp "$1"
done


for((i = 2; i <=1024; i*=2))
do
  echo ===========================================
  echo CUDA "$i" threads per block
    ./bfcuda "$1" "$i"
done

for((i = 2; i <=32; i*=2))
do
    echo ===========================================
    echo MPI  "$i" processos
    mpirun -x MXM_LOG_LEVEL=error -quiet -np $i --allow-run-as-root ./bfmpi "$1"
done