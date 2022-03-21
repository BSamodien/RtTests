#!/bin/bash

root="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
output="$( cd -- "$(dirname "${root}/../.")" >/dev/null 2>&1 ; pwd -P )/.out"

data="${root}/../.out/*.out"

mkdir -p ${output}

for f in ${data}
do
  
  filename="${f##*/}"
  name="${filename%.out}"
  echo "Processing ${name}..."

  max=`grep "Max Latencies" ${f} | tr " " "\n" | sort -n | tail -1 | sed s/^0*//`
  cpu=`cat ${f} | grep "CPU:" | sed -ne 's/# CPU: //p'`
  kernel=`cat ${f} | grep "Kernel:" | sed -ne 's/# Kernel: //p'`
  cores=`cat ${f} | grep "Cores:" | sed -ne 's/# Cores: //p'`
  grep -v -e "^#" -e "^$" ${f} | tr " " "\t" > histogram

  # Create two-column data sets with latency classes and frequency values for each core
  for i in `seq 1 $cores`
  do
    column=`expr $i + 1`
    cut -f1,$column histogram > histogram$i
  done

  echo -n -e "set title \"Latency plot - ${name} [CPU: ${cpu}, Kernel: ${kernel}]\"\n\
  set terminal pngcairo size 1024,768 enhanced font 'Verdana,10'\n\
  set style line 102 lc rgb '#d6d7d9' lt 0 lw 1\n\
  set grid back ls 102\n\
  set style line 101 lc rgb '#808080' lt 1 lw 1\n\
  set border 3 front ls 101\n\
  set tics nomirror out scale 0.75\n\
  set xlabel \"Latency (us), max $max us\"\n\
  set logscale y\n\
  set xrange [0:1000]\n\
  set yrange [0.8:*]\n\
  set format y \"%12.0f\"\n\
  set ylabel \"Number of latency samples\"\n\
  set output \"${output}/${name}.png\"\n\
  plot " > plotcmd

  for i in `seq 1 $cores`
  do
    if test $i != 1
    then
      echo -n ", " >> plotcmd
    fi
    cpuno=`expr $i - 1`
    if test $cpuno -lt 10
    then
      title=" CPU$cpuno"
    else
      title="CPU$cpuno"
    fi
    echo -n "\"histogram$i\" using 1:2 title \"$title\" with histeps" >> plotcmd
  done

  gnuplot -persist < plotcmd

  rm histogram*
  rm plotcmd
done
exit
