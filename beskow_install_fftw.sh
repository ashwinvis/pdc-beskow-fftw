#!/bin/bash -l
source beskow_env.sh

# Customizable variables
# ----------------------
pkgname='fftw'
# FFTW version
pkgver=3.3.7
# Directory in which the source tarball will be downloaded and extracted
srcdir=$srcdir
# Directory to which the compiled FFTW library will be installed
pkgdir="$pkgdir/${pkgname}-${pkgver}"

# Should be no reason to change anything below
# --------------------------------------------
download() {
  mkdir -p ${srcdir}
  cd ${srcdir}

  if [ ! -f ${pkgname}-${pkgver}.tar.gz ]; then
    wget http://www.fftw.org/${pkgname}-${pkgver}.tar.gz
  fi
  echo "Extracting FFTW tarball..."
  tar xzf $pkgname-$pkgver.tar.gz
}

clean() {
  rm -rf ${pkgdir}

  cd ${srcdir}/${pkgname}-${pkgver}-double
  $MAKE -i clean

  cd ${srcdir}/${pkgname}-${pkgver}-single
  $MAKE -i clean
}

build() {
  cd ${srcdir}

  cp -an ${pkgname}-${pkgver} ${pkgname}-${pkgver}-double
  cp -an ${pkgname}-${pkgver} ${pkgname}-${pkgver}-single

  echo $CFLAGS $LDFLAGS
  echo "PWD=$PWD"
  CONFIGURE="$CONFIGURE
                 F77=$FC CC=$CC MPICC=$MPICC \
	         --prefix=${pkgdir} \
                 --enable-shared \
		 --enable-threads \
		 --enable-openmp \
		 --enable-mpi "

  echo $CONFIGURE
  echo $MAKE
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

# clean
build
# check
package
