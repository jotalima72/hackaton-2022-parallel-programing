#!/bin/sh
gcc sequencial-bf.c -o bfseq -std=c99 -O3
mpicc mpi-bf.c -o bfmpi -std=c99 -O3
gcc omp-bf.c -o bfomp -fopenmp -lm -std=c99 -O3
nvcc cuda-bf.cu -o bfcuda

if [[ ! -f "firstValue.dat" ]]; then
  echo codigo sequencial
  ./bfseq "$1"
fi

if [[  -f "speedupOMP.dat" ]]; then
rm -rf speedupOMP.dat
fi


if [[  -f "speedupCUDA.dat" ]]; then
rm -rf speedupCUDA.dat
fi

if [[  -f "speedupMPI.dat" ]]; then
  rm -rf speedupMPI.dat
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

for((i = 2; i <=64; i*=2))
do
    echo ===========================================
    echo MPI  "$i" processos
    mpirun -x MXM_LOG_LEVEL=error quiet -np $i --allow-run-as-root ./bfmpi "$1"
done