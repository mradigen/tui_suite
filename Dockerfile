FROM docker:dind

RUN apk add --no-cache openssh docker-cli

RUN mkdir -p /run/sshd && \
	ssh-keygen -A && \
	mkdir -p /home/tui_suite

WORKDIR /home/tui_suite

COPY . /home/tui_suite

RUN ln -sf /home/tui_suite/sshd_config.conf /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT [ "/home/tui_suite/setup.sh" ]
