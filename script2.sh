#!/bin/bash
echo "shell script for plotting data  using gnuplot"
gnuplot <<EOF
set terminal png font 'Times new roman'
set grid
unset key
set output 'comparison.png'
set xtics 2
set style line 1 lt 2 lc rgb "cyan"   lw 2 
set style line 2 lt 2 lc rgb "red"    lw 2
set style line 3 lt 2 lc rgb "gold"   lw 2
set ytics nomirror
set xlabel "Threads"
set ylabel "Tempo"
set key top left
set key box
set style data lines
plot "speedup.dat" using 2:xtic(1) title "OMP"    ls 1 with linespoints, \
     "speedup_cuda.dat" using 2:xtic(1) title "CUDA"    ls 2 with linespoints

EOF
