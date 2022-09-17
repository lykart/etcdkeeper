FROM golang:1.18-alpine as build

ENV GO111MODULE on
ENV GOPROXY "https://goproxy.io"

WORKDIR /opt
RUN mkdir etcdkeeper
ADD . /opt/etcdkeeper
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod download \
    && go build -o etcdkeeper main.go


FROM alpine:3.15

ENV HOST="0.0.0.0"
ENV PORT="8080"

# RUN apk add --no-cache ca-certificates

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /opt/etcdkeeper
COPY --from=build /opt/etcdkeeper/src/etcdkeeper/etcdkeeper .
ADD assets assets

EXPOSE ${PORT}

ENTRYPOINT sed -i "s/var etcdBase;/var etcdBase=\'$ETCD_BASE\';/g" /opt/etcdkeeper/assets/etcdkeeper/index.html && ./etcdkeeper -h $HOST -p $PORT