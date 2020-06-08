FROM golang:alpine AS builder

WORKDIR /src/xteve

RUN apk add --no-cache git

RUN git clone https://github.com/nurse-curtis/xTeVe.git

RUN go get github.com/koron/go-ssdp
RUN go get github.com/gorilla/websocket
RUN go get github.com/kardianos/osext

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o xteve xTeVe/xteve.go

FROM alpine:latest

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

RUN apk add  --no-cache ffmpeg vlc rsync

WORKDIR /usr/bin

COPY --from=builder /src/xteve/xteve .

EXPOSE 34400
VOLUME /opt/xteve-config
USER 1001:1000

CMD [ "/usr/bin/xteve -config /opt/xteve-config" ]
