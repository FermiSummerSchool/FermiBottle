# FermiBottle DockerFile
# maintained by the FSSC
# Author: Alex Resutle
#
# This is a two stage dockerfile building the fermi science tools
# and related software in a builder container, then copying
# binaries to the final product container.
#
# Build instructions are split variously across separate install
# scripts, or continuous RUN lines.


##########################################################################
#                             Start Builder
##########################################################################

# Use Centos 6 as our base. Name the builder container builder.
# This container will be thrown away once its contents are copied
# into another centos:6 container at the end of the script.
FROM centos:6 as builder

# Install necessary dev packages from YUM, in alphabetical order
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

# Create the astrosoft directory in /home. This will be our
# install target for all astronomy software
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX

# Install Heasarc Ftools from nifty script. Note, we
# must first copy the install script into the container
# before we can execute it, which is unfortunate.
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh

# ScienceTools. Begin by setting some env vars, then
# Running our setup script. Note that this will also upgrade
# the version of python in the Sciencetools.
ENV STNAME ScienceTools-v11r5p3-fssc-20180124
ENV PLAT x86_64-unknown-linux-gnu-libc2.12
ENV STPFX $ASTROPFX/sciencetools
COPY setup_sciencetools.sh $HOME/setup_sciencetools.sh
RUN sh setup_sciencetools.sh && rm setup_sciencetools.sh

# Install pip and necessary tools.
# This should really be its own script, but it isn't because
# of no good reason.
ENV FERMI_DIR ${STPFX}/${PLAT}
RUN source $FERMI_DIR/fermi-init.sh && \
  echo $FERMI_DIR && \
  which python && python --version && \
  curl https://bootstrap.pypa.io/get-pip.py | python && \
  pip install numpy scipy astropy matplotlib jupyter pysu &&\
  pip install pmw pyfits pywcs pyds9 pysqlite fermipy

# Tempo
COPY setup_tempo.sh $HOME/setup_tempo.sh
RUN sh setup_tempo.sh && rm setup_tempo.sh

# pgplot. This should really be its own script.
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


##########################################################################
#                     End Builder, Start final Product
##########################################################################

# Copy build products into a new Container / layer, specifically centos 6
FROM centos:6
MAINTAINER "Fermi LAT Collaboration"

# This is the default location of the shared directoy.
VOLUME ["/data"]

# This is the default command that docker will run if no other command is
# specified, that's fine because we want it to just drop into a bash shell.
# Not do anything fancy.
CMD [ "/bin/bash" ]

# Prepary the Environment of the new Container
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX
ENV FERMI_DIR $ASTROPFX/sciencetools/x86_64-unknown-linux-gnu-libc2.12

# Copy all the important stuff from the builder into the final product.
# Also, set the permissions to give the wheel group ownership.
COPY --from=builder --chown=root:wheel $ASTROPFX/ftools $ASTROPFX/ftools
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo $ASTROPFX/tempo
COPY --from=builder --chown=root:wheel $ASTROPFX/sciencetools $ASTROPFX/sciencetools
COPY --from=builder --chown=root:wheel $ASTROPFX/pgplot $ASTROPFX/pgplot
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo2 $ASTROPFX/tempo2
COPY --from=builder --chown=root:wheel $ASTROPFX/bin $ASTROPFX/bin

# Now install a bunch of Yum packages, not the devel versions.
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

# Give members of the wheel group sudo access to execute all commands
# Redundantly also give this access to the fermi user
RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers


# The entrypoint script is very important. It is the starter script run
# by docker to prepare a specific container for an individual user.
# The entry point will set the UID of the fermi user inside the container
# to be the same as the host user account's UID. That way the user will have
# ownership over any files they create in the shared directory once they
# leave the container.
#
# Also the entrypoint will prepare the environment, create the new
# user directory, source the ScienceTools and the Ftools, and give
# The user a nice colorful shell.
COPY entrypoint /opt/docker/bin/entrypoint
ENTRYPOINT ["/opt/docker/bin/entrypoint"]

###############################################################################
####################### NEW ADDITIONS HERE ####################################
###############################################################################

# RMFIT
RUN yum install -y libXp &&\
 cd $ASTROPFX &&\
 curl https://fermi.gsfc.nasa.gov/ssc/data/analysis/rmfit/rmfit_v432_64bit.tar.gz | tar zxv


