#!/usr/bin/bash

cp $HOME/.ssh/id_rsa.pub .
docker build --build-arg DISPLAY=${DISPLAY} --build-arg XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} --tag my_ubuntu_image .
docker run -it \
	--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
	--mount type=bind,source=${XDG_RUNTIME_DIR},target=${XDG_RUNTIME_DIR} \
	--mount type=bind,source=/nfs/homes/${USER}/.ssh/,target=/root/.ssh/ \
	--name my_ubuntu_container my_ubuntu_image
