#!/bin/sh
gcc bruteForce.c -o bruteForce -std=c99 -O3
mpicc bruteForce-mpi.c -o bruteForce-mpi -std=c99 -O3
gcc bruteForce-omp.c -o bfomp -fopenmp -lm -std=c99 -O3
nvcc bfcuda.cu -o bfcuda

if [[ ! -f "firstValue.dat" ]]; then
  echo codigo sequencial
  ./bruteForce "$1"
fi

if [[  -f "speedupOMP.dat" ]]; then
rm -rf speedupOMP.dat
fi


if [[  -f "speedupCUDA.dat" ]]; then
rm -rf speedupOMP.dat
fi

if [[  -f "speedupMPI.dat" ]]; then
  rm -rf speedupCUDA.dat
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
    mpirun -quiet -np $i --allow-run-as-root ./bruteForce-mpi "$1"
done