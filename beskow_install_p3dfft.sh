#!/bin/bash -l
source beskow_env.sh

# Customizable variables
# ----------------------
pkgname='p3dfft'
# P3DFFT version
pkgver=2.7.5
# Directory in which the source git repository will be downloaded
srcdir="$srcdir"
# Directory to which the compiled p3dfft library will be installed
pkgdir="$pkgdir/${pkgname}-${pkgver}"

# FFTW
# ----
# fftwdir="$(dirname $FFTW_DIR)"
autotoolsdir="/cfs/klemming/nobackup/${USER:0:1}/${USER}/opt"
fftwdir="$autotoolsdir"

# Should be no reason to change anything below
# --------------------------------------------
git_clone() {
  git clone https://github.com/CyrilleBonamy/p3dfft.git ${srcdir}/${pkgname}-${pkgver} --depth=1
  # git clone https://github.com/sdsc/p3dfft.git ${srcdir}/${pkgname}-${pkgver} --depth=10
}

download() {
  mkdir -p ${srcdir}
  cd ${srcdir}

  if [ ! -f ${pkgname}-${pkgver}.tar.gz ]; then
    wget https://github.com/sdsc/p3dfft/archive/v${pkgver}.tar.gz -O ${pkgname}-${pkgver}.tar.gz
  fi
  tar vxzf ${pkgname}-${pkgver}.tar.gz
}

clean() {
  rm -rf ${srcdir}/${pkgname}-${pkgver}
  rm -rf ${pkgdir}
}

prepare() {
  cd ${srcdir}/${pkgname}-${pkgver}
  # Assuming you had installed and stowed libtool into $autotoolsdir
  cat "${autotoolsdir}/share/aclocal/libtool.m4" \
      "${autotoolsdir}/share/aclocal/ltoptions.m4" \
      "${autotoolsdir}/share/aclocal/ltversion.m4" >> aclocal.m4

  echo 'AC_CONFIG_MACRO_DIRS([m4])' >> configure.ac
  sed -i '1s/^/ACLOCAL_AMFLAGS\ \=\ -I\ m4\n/' Makefile.am
  echo 'ACLOCAL_AMFLAGS = -I m4' >> Makefile.am
}

build() {
  cd ${srcdir}/${pkgname}-${pkgver}

  libtoolize && autoheader && aclocal && autoconf && automake --add-missing
  ## If the above fails, use:
  # autoreconf -fvi
  $CONFIGURE \
    --prefix=${pkgdir} \
    --enable-intel \
    --enable-fftw --with-fftw=${fftwdir} \
    CC=${CC} FC=${FC} LDFLAGS=${LDFLAGS}

  $MAKE -j 1
}

package() {
  set -e
  cd ${srcdir}/${pkgname}-${pkgver}
  # $MAKE install
  ## If the above fails, use (with caution):
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
prepare
build
package
