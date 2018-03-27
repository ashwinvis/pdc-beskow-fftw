#!/bin/bash -l

# https://www.pdc.kth.se/support/documents/development.html#compiling-dynamically
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ROOTFS=DSL

# source /etc/profile
module load gcc/7.2.0
module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/18.0.0.128
module add cdt/17.10  # add cdt module
# module load craype-hugepages2M

pkgdir="$SNIC_NOBACKUP/opt/test"
srcdir=$PWD/build

mkdir -p $pkgdir
mkdir -p $srcdir

export MAKEFLAGS="-j$(nproc)"
export CC=icc
export FC=ifort
export MPICC=cc
export MPIFC=ftn

export CFLAGS="-fast -xHost"
export LDFLAGS="-nofor-main"

## Interactive
# CONFIGURE="aprun -n 1 -b ./configure"
# MAKE="aprun -n 1 -d $(nproc) -b make"

## Batch
CONFIGURE="aprun -n 1 ./configure"
# --host=x86_64-unknown-linux-gnu "
MAKE="aprun -n 1 -d $(nproc) make"
# MAKE="aprun -n 1 -cc none make"

module list
