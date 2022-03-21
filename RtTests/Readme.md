# Compiling and running cyclic tests

## 1. Build the RT Kernel patch

The RT Kernel is built as a debian package in a docker container. The script `kernel.sh` will build the container using podman and copy the built packages to a `.out` folder.

## 2. Build cyclic test

The real-time tests are also built in a docker container. The script `rt-build.sh` will build the project and copy all output to a `.out` folder as well.

## 3. Running the test

To measure the latency of the timer, cyclic test is run with a 200ms timer.

```
cyclictest -l10000000 -m -a3 -t1 -n -p90 -i200 -h400 -q > .out/rt-tests.out
```

## 4. Graph the output

The script `test-process.sh` can be used to graph the result a histogram using gnuplot (This needs to be installed seperately).