FROM alpine:latest
RUN apk add --no-cache btop
RUN echo -e '#!/bin/sh\n/usr/bin/btop --utf-force $@' > /usr/local/bin/btop && chmod +x /usr/local/bin/btop
