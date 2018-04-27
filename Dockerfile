FROM centos:6 as builder

RUN yum update -y && \
yum install -y \
  autoconf \
  automake \
  bzip2-devel \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  libpng-devel \
  libSM-devel \
  libX11-devel \
  libXdmcp-devel \
  libXext-devel \
  libXft-devel \
  libXpm-devel \
  libXrender-devel \
  libXt-devel \
  make \
  mesa-libGL-devel \
  ncurses-devel \
  openssl-devel \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline-devel \
  sqlite-devel \
  sudo \
  tar \
  vim \
  wget \
  which \
  zlib-devel && \
yum clean all && \
rm -rf /var/cache/yum

ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX

# Heasarc Ftools
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh

# ScienceTools
ENV STNAME ScienceTools-v11r5p3-fssc-20180124
ENV PLAT x86_64-unknown-linux-gnu-libc2.12
ENV STPFX $ASTROPFX/sciencetools
COPY setup_sciencetools.sh $HOME/setup_sciencetools.sh
RUN sh setup_sciencetools.sh && rm setup_sciencetools.sh

## Install pip
ENV FERMI_DIR ${STPFX}/${PLAT}
RUN source $FERMI_DIR/fermi-init.sh && \
  echo $FERMI_DIR && \
  which python && python --version && \
  curl https://bootstrap.pypa.io/get-pip.py | python && \
  pip install numpy scipy astropy matplotlib jupyter pysu &&\
  pip install pmw pyfits pywcs pyds9 pysqlite

# Tempo
COPY setup_tempo.sh $HOME/setup_tempo.sh
RUN sh setup_tempo.sh && rm setup_tempo.sh

# pgplot
RUN curl -s -L ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz > pgplot5.2.tar.gz &&\
 tar zxvf pgplot5.2.tar.gz &&\
 rm -rf /pgplot5.2.tar.gz &&\
 mkdir -p $ASTROPFX/pgplot &&\
 cd $ASTROPFX/pgplot &&\
 cp /pgplot/drivers.list . &&\
 sed -i -e '71s/!/ /g' drivers.list &&\
 sed -i -e '72s/!/ /g' drivers.list &&\
 /pgplot/makemake /pgplot linux g77_gcc &&\
 sed -i -e 's/^FCOMPL=g77/FCOMPL=gfortran/g' makefile &&\
 make && make cpg && make clean &&\
 chmod -R g+rwx $ASTROPFX/pgplot &&\
 rm -rf /pgplot

# Tempo2
ENV TEMPO2 $ASTROPFX/tempo2/T2runtime
COPY setup_tempo2.sh $HOME/setup_tempo2.sh
RUN sh setup_tempo2.sh && rm setup_tempo2.sh

# DS9
RUN mkdir $ASTROPFX/bin &&\
 cd $ASTROPFX/bin &&\
 curl http://ds9.si.edu/download/centos6/ds9.centos6.7.6.tar.gz | tar zxv


# copy build products into new layer
FROM centos:6
MAINTAINER "Fermi LAT Collaboration"
VOLUME ["/data"]
CMD [ "/bin/bash" ]

ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX
ENV FERMI_DIR $ASTROPFX/sciencetools/x86_64-unknown-linux-gnu-libc2.12
COPY --from=builder --chown=root:wheel $ASTROPFX/ftools $ASTROPFX/ftools
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo $ASTROPFX/tempo
COPY --from=builder --chown=root:wheel $ASTROPFX/sciencetools $ASTROPFX/sciencetools
COPY --from=builder --chown=root:wheel $ASTROPFX/pgplot $ASTROPFX/pgplot
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo2 $ASTROPFX/tempo2
COPY --from=builder --chown=root:wheel $ASTROPFX/bin $ASTROPFX/bin

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
  libpng \
  libSM \
  libX11 \
  libXdmcp \
  libXext \
  libXft \
  libXpm \
  libXrender \
  libXt \
  make \
  mesa-libGL \
  ncurses\
  openssl \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline\
  sqlite \
  sudo \
  tar \
  vim \
  vim-X11 \
  wget \
  which \
  xorg-x11-apps \
  zlib-devel && \
yum clean all && \
rm -rf /var/cache/yum

RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

COPY entrypoint /opt/docker/bin/entrypoint

ENTRYPOINT ["/opt/docker/bin/entrypoint"]
