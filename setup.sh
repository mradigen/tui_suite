#!/bin/sh
set -e

##########
## SSHD ##
##########
/usr/sbin/sshd -D &
SSHD_PID=$!

###################
## Docker Daemon ##
###################
dockerd-entrypoint.sh &
DOCKERD_PID=$!

echo "Waiting for Docker daemon to start..."
DOCKER_SOCKET="/var/run/docker.sock"
while [ ! -S "$DOCKER_SOCKET" ] || ! docker info >/dev/null 2>&1; do
	if ! kill -0 $DOCKERD_PID 2>/dev/null; then
		echo "Docker daemon failed to start!"
		exit 1
	fi
	echo "Docker daemon not ready yet..."
	sleep 1
done
echo "Docker daemon started successfully!"
##################

# Dynamically gets all the applications
APPLICATIONS=$(ls -d */ | sed 's:/$::')

#############
## Cleanup ##
#############
cleanup() {
	echo "Stopping containers"
	for APPLICATION in ${APPLICATIONS}
	do
		docker kill "${APPLICATION}" || true
		docker rm "${APPLICATION}" || true
	done
	echo "Containers stopped"

	# Kill the Docker daemon
	if kill -0 $DOCKERD_PID 2>/dev/null; then
		kill $DOCKERD_PID
		wait $DOCKERD_PID || true
	fi
}
trap cleanup TERM INT EXIT

###########
## Setup ##
###########
#For Alpine
addgroup tui_suite
#For Debian
# groupadd tui_suite

launch() {
	APPLICATION="${1}"
	# Kill and remove existing running containers
	docker kill "${APPLICATION}" || true
	docker rm "${APPLICATION}" || true

	# Setup user perms and groups 
	#For Alpine
	adduser -DH -g "" -h / -s /home/tui_suite/run.sh "${APPLICATION}"
	addgroup "${APPLICATION}" docker
	addgroup "${APPLICATION}" tui_suite
	#For Debian
	# useradd -NM "${APPLICATION}"
	# usermod -aG docker,tui_suite -d / "${APPLICATION}"
	
	passwd -d "${APPLICATION}"

	docker build -t "${APPLICATION}" "${APPLICATION}"

	# Run the container
	docker run -d \
		--name "${APPLICATION}" \
		--read-only \
		-v /home/tui_suite/.runtimefs/root:/root \
		--tmpfs /tmp:rw,size=10m \
		--rm \
		"${APPLICATION}" tail -f /dev/null # tail -f to just keep it alive
}

for APPLICATION in ${APPLICATIONS}
do
	launch "${APPLICATION}"
done

echo "All containers running"

wait $SSHD_PID
cleanup
