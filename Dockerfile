FROM centos:6 as builder

RUN yum update -y && \
yum install -y \
  autoconf \
  automake \
  bzip2 \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  libSM-devel \
  libX11-devel \
  libXext-devel \
  libXft-devel \
  libXpm-devel \
  libXrender-devel \
  libXt-devel \
  make \
  mesa-libGL-devel \
  ncurses-devel \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline-devel \
  sudo \
  tar \
  vim \
  which \
  zlib-devel && \
yum clean all && \
rm -rf /var/cache/yum

ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX

# ScienceTools
ENV STNAME ScienceTools-v11r5p3-fssc-20180124
ENV STPLAT x86_64-unknown-linux-gnu-libc2.12
ENV STPFX $ASTROPFX/sciencetools
# COPY setup_sciencetools.sh $HOME/setup_sciencetools.sh
# RUN sh setup_sciencetools.sh && rm setup_sciencetools.sh

RUN curl -s -L \
  https://fermi.gsfc.nasa.gov/ssc/data/analysis/software/v11r5p3/ScienceTools-v11r5p3-fssc-20180124-source.tar.gz > st.tar.gz && \
  tar zxf st.tar.gz && rm -f st.tar.gz

## Update Python
RUN cd /${STNAME}/external && \
  rm -rf python && \
  curl -s -L https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz > python.tgz && \
  tar zxf python.tgz && \
  rm -f python.tgz && \
  mv Python-2.7.14 python && cd /

## Build the Sciencetools
RUN mkdir -p ${STPFX} &&\
 sed -i -e 's/h_external_components=.*/h_external_components="clhep cppunit f2c\
 fftw gtversion python gsl healpix root minuit2 swig\
 xerces"/g' /${STNAME}/BUILD_DIR/configure && \
 cd ${STNAME}/BUILD_DIR && \
 ./configure --with-root --prefix=${STPFX} &&\
 ./hmake && ./hmake install && cd /

## Install pip
RUN curl -s -L https://bootstrap.pypa.io/get-pip.py > get-pip.py && \
  FERMI_DIR=${STPFX}/${STNAME}/${STPLAT} && \
  source $FERMI_DIR/fermi-init.sh && \
  python get-pip.py

# Heasarc Ftools
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh

# # Tempo
# COPY setup_tempo.sh $HOME/setup_tempo.sh
# RUN sh setup_tempo.sh && rm setup_tempo.sh

# # Tempo2
# ENV TEMPO2 $ASTROPFX/tempo2/T2runtime
# COPY setup_tempo2.sh $HOME/setup_tempo2.sh
# RUN sh setup_tempo2.sh && rm setup_tempo2.sh


# copy build products into new layer
FROM centos:6
MAINTAINER "Fermi LAT Collaboration"
VOLUME ["/data"]
CMD [ "/bin/bash" ]

ENV ASTROPFX /home/astrosoft
ENV STNAME ScienceTools-v11r5p3-fssc-20180124-x86_64-unknown-linux-gnu-libc2.12/x86_64-unknown-linux-gnu-libc2.12
RUN mkdir -p $ASTROPFX
# COPY --from=builder --chown=root:wheel /opt/anaconda /opt/anaconda
COPY --from=builder --chown=root:wheel $ASTROPFX/ftools $ASTROPFX/ftools
COPY --from=builder --chown=root:wheel $ASTROPFX/$STNAME $ASTROPFX/$STNAME

RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf && \
yum update -y && \
yum install -y \
  bzip2 \
  dejavu-lgc-sans-fonts \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  gedit \
  git \
  libSM \
  libX11 \
  libXext \
  libXft \
  libXpm \
  libXrender \
  libXt \
  make \
  mesa-libGL \
  ncurses\
  patch \
  perl \
  readline\
  sudo \
  tar \
  vim \
  vim-X11 \
  which \
  xorg-x11-apps \
  zlib-devel \
&& \
yum clean all && \
rm -rf /var/cache/yum

RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

# COPY entrypoint /opt/docker/bin/entrypoint

# ENTRYPOINT ["/opt/anaconda/bin/tini", "--", "/opt/docker/bin/entrypoint"]
