GROUP=38264 #systems group id
echo sudo adduser --gid $GROUP $1
echo sudo adduser $1 sudo
echo sudo adduser $1 docker
