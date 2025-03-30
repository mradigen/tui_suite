FROM alpine:latest
RUN apk add --no-cache lazygit
RUN echo -e '#!/bin/sh\n/usr/bin/lazygit -p /root/Repositories/chota $@' > /usr/local/bin/lazygit && chmod +x /usr/local/bin/lazygit
