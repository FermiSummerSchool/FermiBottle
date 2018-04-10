#! /bin/sh

cd $ASTROPFX
curl -s -L https://fermi.gsfc.nasa.gov/ssc/data/analysis/software/v11r5p3/ScienceTools-v11r5p3-fssc-20180124-source.tar.gz > st.tar.gz
tar zxf st.tar.gz
rm st.tar.gz

## Update Python
cd ${STNAME}/external
rm -rf python
curl -s -L https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz > python.tgz
tar zxf python.tgz
rm python.tgz
mv Python-2.7.14 python

## Build the Sciencetools
cd ../BUILD_DIR
mkdir -p ${STPFX}
./configure --prefix=${STPFX}
./hmake && ./hmake install

## Install pip
curl -s -L https://bootstrap.pypa.io/get-pip.py > get-pip.py
FERMI_DIR=${STPFX}/${STNAME}/${STPLAT}
source $FERMI_DIR/fermi-init.sh
python get-pip.py
