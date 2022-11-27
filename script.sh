#!/bin/sh
gcc sequencial-bf.c -o bfseq -std=c99 -O3
mpicc mpi-bf.c -o bfmpi -std=c99 -O3
gcc omp-bf.c -o bfomp -fopenmp -lm -std=c99 -O3

if [[ ! -f "firstValue.dat" ]]; then
  echo codigo sequencial
  ./bfseq "$1"
fi

if [[  -f "speedup.dat" ]]; then
rm -rf speedup.dat
fi

if [[  -f "speedupMPI.dat" ]]; then
  rm -rf speedupMPI.dat
fi


for((i = 2; i <=64; i*=2))
do
  echo opemMP thread "$i"
    OMP_NUM_THREADS=$i ./bfomp "$1"
done

for((i = 2; i <=64; i*=2))
do
    echo MPI processo "$i"
    mpirun -x MXM_LOG_LEVEL=error -quiet -np $i --allow-run-as-root ./bfmpi "$1"
done