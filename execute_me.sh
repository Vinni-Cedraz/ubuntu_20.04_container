#!/usr/bin/bash

cp $HOME/.ssh/id_rsa.pub .
docker build -t my_ubuntu_image .
