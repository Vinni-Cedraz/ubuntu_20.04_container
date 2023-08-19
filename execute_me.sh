#!/usr/bin/bash
docker build --build-arg DISPLAY=${DISPLAY} --build-arg XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} --tag my_ubuntu_image .
docker run -it \
	--mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
	--mount type=bind,source=${XDG_RUNTIME_DIR},target=${XDG_RUNTIME_DIR} \
	--mount type=bind,source=${HOME}/.ssh/,target=/root/.ssh/ \
	--mount type=bind,source=/usr/local/lib/libmlx.a,target=/usr/lib/libmlx.a \
	--mount type=bind,source=/usr/local/include/mlx.h,target=/usr/include/mlx.h \
	--mount type=bind,source=/usr/local/share/man/man3/mlx.3,target=/usr/man/man3/mlx.3 \
	--name my_ubuntu_container my_ubuntu_image
