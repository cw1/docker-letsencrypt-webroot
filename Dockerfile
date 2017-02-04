FROM alpine:latest
RUN apk add --update certbot docker && rm -rf /var/cache/apk/*
ADD start.sh /start.sh
RUN chmod 777 /start.sh
ENTRYPOINT [ "/start.sh" ]
