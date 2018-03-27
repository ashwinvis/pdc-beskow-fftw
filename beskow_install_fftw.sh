#!/bin/bash -l
source beskow_install_base.sh

# Customizable variables
# ----------------------
pkgname='fftw'
# FFTW version
pkgver=3.3.7
# Directory in which the source tarball will be downloaded and extracted
srcdir=$srcdir
# Directory to which the compiled FFTW library will be installed
pkgdir="$pkgdir/${pkgname}-${pkgver}"

export CC="$CC"
export MPICC="$MPICC"
export F77="$FC"

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


  echo $CFLAGS $LDFLAGS
  CONFIGURE="$CONFIGURE
                 F77=$F77 CC=$CC MPICC=$MPICC \
	         --prefix=${pkgdir} \
                 --enable-shared \
		 --enable-threads \
		 --enable-openmp \
		 --enable-mpi "

  MAKE="make"
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
  $MAKE check

  cd ${srcdir}/${pkgname}-${pkgver}-single
  $MAKE check
}

package() {
  set -e
  cd ${srcdir}/${pkgname}-${pkgver}-double
  $MAKE install

  cd ${srcdir}/${pkgname}-${pkgver}-single
  $MAKE install

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
