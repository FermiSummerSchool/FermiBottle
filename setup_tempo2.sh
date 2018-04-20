#! /bin/sh
# Install

# The repository version has build instructions in the readme file (or see the front page of the bitbucket site). The build instructions for the tarballs are similar but you do not need the bootstrap step, and you do not need a working installation of libtool or autoconf. Copy the runtime files, i.e. clock corrections, planitary ephemerdis etc to $TEMPO2, e.g.

#   cp -r T2runtime $TEMPO2

# Where $TEMPO2 can point to any directory you want this to be installed into. (typically $TEMPO2=/usr/local/share).

# Simply run:

#   ./configure --prefix=$PREFIX
#   make
#   make plugins
#   make install plugins-instal

# where $PREFIX is the location you want to install tempo2. Typically $PREFIX=/usr/local

# There are a few other plugins that are unsupported, in that they may use additional libraries or undocumented features and are not checked as thoroughly. To build eveything, including the unsupported plugins do

#   make complete && make complete install

# Always test your newly built tempo2 by running

#   make check

# in your build area.
TEMPO2PFX=$ASTROPFX/tempo2
XINC="/usr/include"
XLIB="/usr/lib64"
CFITSIO="$ASTROPFX/ftools/$PLAT"
FFTW="$ASTROPFX/ftools/$PLAT"
GSL="$ASTROPFX/ftools/$PLAT"
mkdir -p $TEMPO2PFX
curl -s -L https://bitbucket.org/psrsoft/tempo2/downloads/tempo2-2018.02.1.tar.gz > tempo2.tar.gz
tar zxf tempo2.tar.gz
rm -rf  tempo2.tar.gz
cd tempo2-2018.02.1
cp -r T2runtime $TEMPO2PFX
./configure \
  F77=gfortran \
  --prefix=$TEMPO2PFX \
  --x-includes=$XINC \
  --x-libraries="${XLIB} -lXdmcp" \
  --with-pgplot-extra="-lX11 -lXdmcp -lz" \
  --with-cfitsio-dir=$CFITSIO \
  --with-fftw3-dir=$FFTW \
  --with-gsl-prefix=$GSL \
  --with-x \
  CFLAGS="-fPIC -I$FERMIPFX/include -I$FERMIPFX/include/pgplot" \
  FFLAGS=-fPIC \
  CXXFLAGS="-I$FERMIPFX/include -I$FERMIPFX/include/pgplot" \
  LDFLAGS=-L$FERMIPFX/lib \
  PGPLOT_DIR="$FERMIPFX/lib -lpng" \
  PGPLOT_DEV=/xwindow
make
make install
make plugins
make plugins-install
cd ../
rm -rf tempo2-2018.02.1
chmod -R g+rwx $TEMPO2PFX
