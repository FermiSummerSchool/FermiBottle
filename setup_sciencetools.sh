#! /bin/sh

curl -s -L https://fermi.gsfc.nasa.gov/ssc/data/analysis/software/v11r5p3/ScienceTools-v11r5p3-fssc-20180124-source.tar.gz > st.tar.gz
tar zxf st.tar.gz
rm -f st.tar.gz

## Update Python
cd /${STNAME}/external
rm -rf python
curl -s -L https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz > python.tgz
tar zxf python.tgz
rm -f python.tgz
mv Python-2.7.14 python
cd /

## Build the Sciencetools
mkdir -p ${STPFX}
sed -i -e 's/h_external_components=.*/h_external_components="clhep cppunit f2c fftw gtversion python gsl healpix root minuit2 swig xerces"/g' /${STNAME}/BUILD_DIR/configure
cd ${STNAME}/BUILD_DIR
./configure --prefix=${STPFX} --with-root --enable-collapse
./hmake
./hmake install
chmod -R g+rwx $STPFX
