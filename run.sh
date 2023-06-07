#!/usr/bin/bash

cp ~/.ssh/id_rsa.pub .
docker build -t my_ubuntu_image .
