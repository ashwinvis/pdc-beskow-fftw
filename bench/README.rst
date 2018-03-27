3d FFT with distributed memory (MPI)
====================================

Different libraries

- fftw3 and fftw3-mpi
  
- pfft https://github.com/mpip/pfft

  (with a Python binding https://github.com/rainwoodman/pfft-python)

- p3dfft https://github.com/sdsc/p3dfft


HOWTO
=====
Meant only for Beskow. Run::

        make clean build test_bench.out
        make test
        make testmpi
