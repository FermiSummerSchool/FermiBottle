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

mkdir -p $ASTROPFX
$CONDAINSTFERMI pgplot
TEMPO2DIR="tempo2-2018.02.1"
curl -s -L https://bitbucket.org/psrsoft/tempo2/downloads/tempo2-2018.02.1.tar.gz > tempo2.tar.gz
tar zxvf tempo2.tar.gz
rm -rf  tempo2.tar.gz
cd $TEMPO2DIR
# bootstrap
cp -r T2runtime $TEMPO2
./configure --prefix=$ASTROPFX
make
make install
make plugins
make plugins-install
cd ../
rm -rf $TEMPO2DIR
