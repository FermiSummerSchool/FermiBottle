# FermiBottle documentation

## Install instructions

### Acquire the Docker Image

##### Using DockerHub

`docker pull areustle/fermibottle`

##### Using local tarball

`unzip fermibottle.tar.zip && docker load < fermibottle.tar`

### Run the image to create a container

```
docker run -it
  -v HOST_SHARED_DIRECTORY:/data areustle/fermibottle
```

## Build instructions

`cd FermiBottle && docker image build -t fermibottle .`

## Sharing instructions

### Create a local tarball

 1. Save a built image `docker save fermibottle -o fermibottle.tar`
 1. Compress it with zip, to be nice to windows: `zip fermibottle.tar`

### Upload to dockerhub 

 1. Find the hash of your image `docker images`
 1. Tag the image `docker tag IMAGE_HASH areustle/fermibottle:TAGNAME`
 1. Push to dockerhub `docker push areustle/fermibottle`


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
