FROM alpine:latest
RUN apk add --update certbot docker && rm -rf /var/cache/apk/* && mkdir -p /etc/letsencrypt
ADD start.sh /start.sh
RUN chmod 777 /start.sh /etc/letsencrypt
ENTRYPOINT [ "/start.sh" ]
