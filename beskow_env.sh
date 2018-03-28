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

export pkgdir="$SNIC_NOBACKUP/opt/test"
export srcdir="$SNIC_NOBACKUP/pdc-beskow-fluidfft/build"

mkdir -p $pkgdir
mkdir -p $srcdir

echo "pkgdir = "$pkgdir
echo "srcdir = "$srcdir

export MAKEFLAGS="-j$(nproc)"
export CC=cc
export FC=ftn
export MPICC=cc
export MPIFC=ftn

export CFLAGS="-fast -xHost"
export LDFLAGS="-nofor-main"

## Commands
# CONFIGURE="aprun -n 1 -d 1 ./configure"
CONFIGURE="aprun -n 1 -b ./configure --host=x86_64-unknown-linux-gnu"
# CONFIGURE="./configure"

# MAKE="aprun -n 1 -d $(nproc) make"
MAKE="aprun -n 1 -d $(nproc) -b make"
# MAKE="aprun -n 1 -cc none make"

module list
