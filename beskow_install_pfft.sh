#!/bin/bash -l
source beskow_env.sh

# FFTW
# ----
# FFTW == 3.3.4 requires patching, whereas 3.3.5 and later versions should work
# as it is. See: https://github.com/mpip/pfft#install

# You can use the same fftw directory that for p3dfft
fftwdir=$(dirname $pkgdir)

# Alternatively, set fftwdir as an empty string and mention fftw include and
# library directories seperately below
# fftwinc=$FFTW_INC
# fftwlib=$FFTW_DIR

# Customizable variables
# ----------------------
pkgname='pfft'
# PFFT version
pkgver="1.0.8-alpha"
# Directory in which the source git repository will be downloaded
srcdir="$srcdir"
# Directory to which the compiled pfft library will be installed
pkgdir="$pkgdir/${pkgname}-${pkgver}"

# Should be no reason to change anything below
# --------------------------------------------
git_clone() {
  git clone https://github.com/mpip/pfft.git ${srcdir}/${pkgname}-${pkgver} --depth=10
}

download() {
  mkdir -p ${srcdir}
  cd ${srcdir}

  if [ ! -f ${pkgname}-${pkgver}.tar.gz ]; then
    wget http://www.tu-chemnitz.de/~potts/workgroup/pippig/software/${pkgname}-${pkgver}.tar.gz
  fi
  tar vxzf ${pkgname}-${pkgver}.tar.gz
}

clean() {
  rm -rf ${srcdir}/${pkgname}-${pkgver}
  rm -rf ${pkgdir}
}

build() {
  cd ${srcdir}/${pkgname}-${pkgver}
  export LANG=C
  ./bootstrap.sh
  CONFIGURE="$CONFIGURE
            --prefix=${pkgdir} \
            CC=${CC} FC=${FC} MPICC=${CC} MPIFC=${FC} "
  if [ -n "$fftwdir" ]; then
    CONFIGURE+="--with-fftw3=${fftwdir}"
  else
    CONFIGURE+="CPPFLAGS=-I${fftwinc}  LDFLAGS=-L${fftwlib}"
  fi
  echo ${CONFIGURE}
  ${CONFIGURE}
  ${MAKE}
}

package() {
  set -e
  cd ${srcdir}/${pkgname}-${pkgver}
  $MAKE install

  set +e
  cd ${pkgdir}/..
  stow -v $pkgname-$pkgver
}


# Execute the functions above
# ---------------------------
clean
if [ ! -d  ${srcdir}/${pkgname}-${pkgver} ]
then
  ## Use any one of the following
  git_clone
  # download
fi
build
package
