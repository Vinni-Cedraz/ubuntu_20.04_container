#!/usr/bin/bash

user=root
user_home=/root

xdg_runtime_owner_uid=$(stat -c %u $XDG_RUNTIME_DIR)

# Check if the owner's UID is 0 (root)
if [ "$xdg_runtime_owner_uid" -eq 0 ]; then
	echo "owner of $XDG_RUNTIME_DIR is root"; 
else
    user=myuser
    user_home=/home/myuser
	echo "owner of $XDG_RUNTIME_DIR is not root"; 
fi

sudo docker build  \
	--build-arg _USER=$user\
	--build-arg _USER_HOME=$user_home \
	--build-arg DISPLAY=${DISPLAY} \
	--build-arg XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	--tag my_ubuntu_image .

sudo docker run -it \
	--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
	--mount type=bind,source=${XDG_RUNTIME_DIR},target=${XDG_RUNTIME_DIR} \
	--mount type=bind,source=${HOME}/.ssh/,target=${user_home}/.ssh/ \
	--mount type=bind,source=/usr/local/lib/libmlx.a,target=/usr/lib/libmlx.a \
	--mount type=bind,source=/usr/local/include/mlx.h,target=/usr/include/mlx.h \
	--mount type=bind,source=/usr/local/share/man/man3/mlx.3,target=/usr/man/man3/mlx.3 \
	--name my_ubuntu_container -p 8080:123 my_ubuntu_image
