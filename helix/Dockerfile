FROM alpine:latest
RUN apk add --no-cache helix
RUN echo -e '#!/bin/sh\n/usr/bin/hx $@' > /usr/local/bin/helix && chmod +x /usr/local/bin/helix
