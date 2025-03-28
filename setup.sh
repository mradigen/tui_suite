#!/bin/sh

# Dynamically gets all the applications
APPLICATIONS=$(ls -d */ | sed 's:/$::')

# Cleanup
cleanup() {
	echo "Stopping containers"
	for APPLICATION in ${APPLICATIONS}
	do
		docker kill "${APPLICATION}"
		docker rm "${APPLICATION}"
	done
	echo "Containers stopped"
}
trap cleanup TERM INT EXIT

#For Alpine
addgroup tui_suite
addgroup -g 967 docker
#For Debian
# groupadd tui_suite

for APPLICATION in ${APPLICATIONS}
do
	# Kill and remove existing running containers
	docker kill "${APPLICATION}"
	docker rm "${APPLICATION}"

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
		-v /home/tui_suite/.runtimefs/tmp:/tmp:rw \
		-v /home/tui_suite/.runtimefs/root:/root:rw \
		--rm \
		"${APPLICATION}" tail -f /dev/null # tail -f to just keep it alive
done

/usr/sbin/sshd -D &
SSHD_PID=$!

echo "All containers running"

wait $SSHD_PID
cleanup
