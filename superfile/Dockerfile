ARG PACKAGE=superfile \
	VERSION=1.2.1 \
	OS=linux \
	ARCH=amd64
ARG FILE_NAME=${PACKAGE}-${OS}-v${VERSION}-${ARCH}

FROM alpine:latest AS superfile-builder
RUN apk add --no-cache curl tar
ARG FILE_NAME
ARG VERSION
RUN curl -sLO "https://github.com/yorukot/superfile/releases/download/v${VERSION}/${FILE_NAME}.tar.gz" \
	&& tar -xzf "${FILE_NAME}.tar.gz"

FROM golang:alpine AS sleeper-builder
WORKDIR /app
RUN echo "module tail" > go.mod
RUN echo 'package main; import "time"; func main() { for { time.Sleep(time.Hour) } }' > main.go
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o tail .

FROM scratch
ARG FILE_NAME
ENV PATH="/" \
	HOME="/root" \
	SPF_STRICT_CONFIG=false
COPY --from=superfile-builder /dist/${FILE_NAME}/spf /superfile
COPY --from=sleeper-builder /app/tail /tail
WORKDIR /root
