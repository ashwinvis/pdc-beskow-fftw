#!/bin/bash

# Customizable variables
# ----------------------
pkgname='fftw'
# FFTW version
pkgver=3.3.7
# Directory in which the source tarball will be downloaded and extracted
srcdir=$PWD
# Directory to which the compiled FFTW library will be installed
pkgdir="$SNIC_NOBACKUP/opt/pkg-mar18/${pkgname}-${pkgver}"
export MAKEFLAGS="-j$(nproc)"

export CC="icc"
export MPICC="cc"
export F77="ifort"

# Should be no reason to change anything below
# --------------------------------------------
download() {
  mkdir -p ${srcdir}
  cd ${srcdir}

  if [ ! -f ${pkgname}-${pkgver}.tar.gz ]; then
    wget http://www.fftw.org/${pkgname}-${pkgver}.tar.gz
  fi
  tar vxzf $pkgname-$pkgver.tar.gz
}

clean() {
  rm -rf ${pkgdir}

  cd ${srcdir}/${pkgname}-${pkgver}-double
  make clean

  cd ${srcdir}/${pkgname}-${pkgver}-single
  make clean
}

build() {
  cd ${srcdir}

  cp -a ${pkgname}-${pkgver} ${pkgname}-${pkgver}-double
  cp -a ${pkgname}-${pkgver} ${pkgname}-${pkgver}-single


  # do not use upstream default CFLAGS for -march/-mtune
  export CFLAGS="-fast -xHost"
  # export CFLAGS="-fast -xHost $(cc --cray-print-opts=cflags)"
  # export LDFLAGS="$(cc --cray-print-opts=libs)"
  echo $CFLAGS $LDFLAGS
  # CONFIGURE="aprun -n 1
  CONFIGURE="
                 ./configure F77=$F77 CC=$CC MPICC=$MPICC \
	         --prefix=${pkgdir} \
                 --enable-shared \
		 --enable-threads \
		 --enable-openmp \
		 --enable-mpi "
                 # --host=x86_64-unknown-linux-gnu "

  MAKE="make"
  # MAKE="aprun -n 1 -cc none make"
  # MAKE="aprun -n 1 -cc none make"
  # build double precision
  cd ${srcdir}/${pkgname}-${pkgver}-double
  $CONFIGURE --enable-sse2 --enable-avx --enable-avx2
  $MAKE

  # build & install single precision
  cd ${srcdir}/${pkgname}-${pkgver}-single
  $CONFIGURE --enable-float --enable-sse2 --enable-avx --enable-avx2
  $MAKE
}

check() {
  cd ${srcdir}/${pkgname}-${pkgver}-double
  make check

  cd ${srcdir}/${pkgname}-${pkgver}-single
  make check
}

package() {
  set -e
  cd ${srcdir}/${pkgname}-${pkgver}-double
  make install

  cd ${srcdir}/${pkgname}-${pkgver}-single
  make install

  set +e
  cd ${pkgdir}/..
  stow -v $pkgname-$pkgver
}


# Execute the functions above
# ---------------------------
if [ ! -d  ${srcdir}/${pkgname}-${pkgver} ]
then
  download
fi

clean
build
# check
package
