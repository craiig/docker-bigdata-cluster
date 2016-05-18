#!/bin/bash
GROUP=38264 #systems group id
if [[ $1 == "" ]]; then
	echo "usage: $0 <username>"
	exit 1
fi
sudo adduser --gid $GROUP $1
sudo adduser $1 sudo
sudo adduser $1 docker
