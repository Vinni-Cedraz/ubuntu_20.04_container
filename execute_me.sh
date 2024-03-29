#!/usr/bin/bash

user="root"
user_home="/root"

# Check ownership of host's XDG_RUNTIME_DIR 
if ls -ld "$XDG_RUNTIME_DIR" | grep -q "root"; then
	# then it means it's not owned by root so we will to create a non-root user
	# for the container for GUI apps to work correctly!
    user="myuser"
    user_home="/home/myuser"
fi

docker build  \
	--build-arg _USER=$user\
	--build-arg _USER_HOME=$user_home \
	--build-arg DISPLAY=${DISPLAY} \
	--build-arg XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	--tag my_ubuntu_image .

docker run -it \
	--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
	--mount type=bind,source=${XDG_RUNTIME_DIR},target=${XDG_RUNTIME_DIR} \
	--mount type=bind,source=${HOME}/.ssh/,target=${user_home}/.ssh/ \
	--mount type=bind,source=/usr/local/lib/libmlx.a,target=/usr/lib/libmlx.a \
	--mount type=bind,source=/usr/local/include/mlx.h,target=/usr/include/mlx.h \
	--mount type=bind,source=/usr/local/share/man/man3/mlx.3,target=/usr/man/man3/mlx.3 \
	--name my_ubuntu_container -p 8080:123 my_ubuntu_image \
