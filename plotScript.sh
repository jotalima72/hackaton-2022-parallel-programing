#!/bin/sh
echo "using gnuplot to OMP"
gnuplot <<EOF
set terminal png font 'Times new roman'
set grid
unset key
set output 'OMP.png'

set style line 1 lt 2 lc rgb "cyan"   lw 2 
set style line 2 lt 2 lc rgb "red"    lw 2
set style line 3 lt 2 lc rgb "gold"   lw 2
set ytics nomirror
set xlabel "Threads"
set ylabel "SpeedUp"
set key top left
set key box
set style data lines
plot "speedupOMP.dat" using 2:xtic(1) title "OMP"    ls 1 with linespoints

EOF

echo "using gnuplot to MPI"
gnuplot <<EOF
set terminal png font 'Times new roman'
set grid
unset key
set output 'MPI.png'

set style line 1 lt 2 lc rgb "red"   lw 2 
set style line 2 lt 2 lc rgb "cyan"    lw 2
set style line 3 lt 2 lc rgb "gold"   lw 2
set ytics nomirror
set xlabel "Processos"
set ylabel "SpeedUp"
set key top left
set key box
set style data lines
plot "speedupMPI.dat"  using 2:xtic(1) title "MPI"    ls 1 with linespoints

EOF


echo "using gnuplot to CUDA"
gnuplot <<EOF
set terminal png font 'Times new roman'
set grid
unset key
set output 'CUDA.png'

set style line 1 lt 2 lc rgb "gold"   lw 2 
set style line 2 lt 2 lc rgb "red"    lw 2
set style line 3 lt 2 lc rgb "cyan"   lw 2
set ytics nomirror
set xlabel "Threads per Block"
set ylabel "SpeedUp"
set key top left
set key box
set style data lines
plot "speedupCUDA.dat" using 2:xtic(1) title "CUDA"    ls 1 with linespoints

EOF