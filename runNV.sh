#!/bin/bash
echo "Ho ricevuto in ingresso un numero parametri di: $# "
(( $# > 0 )) || { echo "Numero parametri insufficienti: cmd container [user]"; exit 255; }
echo "Container nome: $1"
clion=$(echo /usr/local/clion*)
pycharm=$(echo /usr/local/pycharm*)

xhost +
(( $# == 2 )) && {
	echo "Nome utente: $2"
	export OPT_CMD="-v /home/$2:/home/$2 --workdir /home/$2"
	test -d /usr/local/MATLAB && export OPT_CMD="-v /usr/local/MATLAB:/usr/local/MATLAB:ro $OPT_CMD"
	test -d $clion && export OPT_CMD="-v $clion:$clion:ro $OPT_CMD"
	test -d $pycharm && export OPT_CMD="-v $pycharm:$pycharm:ro $OPT_CMD"
	export OPT_CMD="-e LOCAL_USER_ID=$(id -u $2) -e LOCAL_GROUP_ID=$(id -g $2) -e LOCAL_GROUP_NAME=$2 -e USER=$USER --user $(id -u $2):$(id -g $2) $OPT_CMD"
	echo "OPTIONS: $OPT_CMD"
 }
nvidia-docker run \
	--net=host \
	--privileged \
	-v/etc/group:/etc/group:ro \
	-v/etc/passwd:/etc/passwd:ro \
	-v/etc/shadow:/etc/shadow:ro \
	-v/dev:/dev \
	-v/etc/sudoers.d:/etc/sudoers.d:ro \
	-v /tmp/X11-unix:/tmp/X11-unix \
	-e DISPLAY=$DISPLAY \
	-e "QT_X11_NO_MITSHM=1" \
	-e "XDG_RUNTIME_DIR=/tmp" \
	-e "PATH=$PATH:/home/$2/bin" \
	-e "LD_LIBRARY_PATH=$( ls -d -1 /usr/lib/nvidia*  )" \
	-v /usr/lib/nvidia-410:/usr/lib/nvidia-410:ro \
	--add-host="docker_$1:127.0.0.1" \
	$OPT_CMD \
	-ti -h docker_$1 $1
