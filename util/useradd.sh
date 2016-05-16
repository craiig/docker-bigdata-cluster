GROUP=38264 #systems group id
if [[ $1 == "" ]]; then
	echo "usage: $0 <username>"
	exit 1
fi
echo sudo adduser --gid $GROUP $1
echo sudo adduser $1 sudo
echo sudo adduser $1 docker
