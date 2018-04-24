# STBottle documentation

## Install instructions

### Acquire the Docker Image

##### Using DockerHub

`docker pull areustle/stbottle`

##### Using local tarball

`unzip stbottle.tar.zip && docker load < stbottle.tar`

### Run the image to create a container (Linux)

```
docker run -it \
-e HOST_USER_ID=`id -u $USER` \
-e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v `pwd`:/data \
-p 8888:8888 \
areustle/stbottle
```

### Run the image to create a container (MacOS)
This requires XQuartz to be installed and the "Allow Connections from Network Clients" option to be selected in 
XQuartz > Preferences > Security. 

Quit XQuartz after setting this option.

On the command line run:

```
xhost + 127.0.0.1 && \
docker run -it \
-e HOST_USER_ID=`id -u $USER` \
-e DISPLAY=docker.for.mac.localhost:0 \
-v `pwd`:/data \
-p 8888:8888 \
areustle/stbottle
```

## Usage instructions

Exit and shutdown an existing container with `exit` in the container's shell

Find the CONTAINER_ID of a container with `docker ps -a`

Restart a stopped container in the background with `docker start CONTAINER_ID` or `docker start CONTAINER_NAME`

Attach to a running container (get into the shell) with `docker attach CONTAINER_ID` or `docker attach CONTAINER_NAME`

#### Jupyter Notebooks

Run a jupyter notebook from within the container with 
`jupyter notebook --ip 0.0.0.0 --no-browser`

## Build instructions

`cd FermiBottle && docker image build -t stbottle .`

## Sharing instructions

### Create a local tarball

 1. Save a built image `docker save stbottle -o stbottle.tar`
 1. Compress it with zip, to be nice to windows: `zip stbottle.tar`

### Upload to dockerhub 

 1. Find the hash of your image `docker images`
 1. Tag the image `docker tag IMAGE_HASH areustle/fermibottle:TAGNAME`
 1. Push to dockerhub `docker push areustle/stbottle`


## Developers notes

Mostly this container was adapted from the conda-forge linux-anvil container
https://github.com/conda-forge/docker-images

I hope the Dockerfile is self-documenting with its comments, but here's a
summary.

FermiBottle is built in a Centos 6 container, with the stage name 'builder'.
The Yum package manager is used to update the build toolchain. Next scripts are
called to install ftools, anaconda, fermitools, tempo(s) etc. This builder
container has outlived its usefulness, so a newer, younger container is 
spun up and the binaries from builder are copied into it. The entrypoint script 
is copied and set as the docker entrypoint after being passed through tini, the
tini-est init process. A volume point is mounted to '/data' and a default
command is set to launch a bash shell.

Entrypoint will create the fermi user, set permissions and make symbolic
links for the build products. It will pass input prompts through 'gosu' to
provide a colorful, functional terminal experience for the fermi user that will 
properly handle keyboard interrupts and kernal signals.
