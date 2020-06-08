FROM golang:alpine AS builder

WORKDIR /src/xteve

RUN apk add --no-cache git

RUN git clone https://github.com/nurse-curtis/xTeVe.git

RUN go get github.com/koron/go-ssdp
RUN go get github.com/gorilla/websocket
RUN go get github.com/kardianos/osext

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o xteve xTeVe/xteve.go

FROM alpine:latest

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates
RUN rm -rf /var/cache/apk/*
RUN apk add  --no-cache ffmpeg vlc rsync bash busybox-suid su-exec curl

# Volumes
VOLUME /config
VOLUME /root/.xteve
VOLUME /tmp/xteve

COPY --from=builder /src/xteve/xteve /usr/bin/

ADD cronjob.sh /
ADD entrypoint.sh /
ADD sample_cron.txt /
ADD sample_xteve.txt /

# Set executable permissions
RUN chmod +x /entrypoint.sh
RUN chmod +x /cronjob.sh
RUN chmod +x /usr/bin/xteve

EXPOSE 34400

# CMD [ "/usr/bin/xteve -config /opt/xteve-config" ]
# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]
