FROM alpine:3.20

ENV TZ=Europe/Paris

RUN apk add --no-cache bash postfix postfix-mysql ca-certificates spamassassin-client tzdata openssl && \
       ln -s /usr/share/zoneinfo/$TZ /etc/localtime

COPY config/ /etc/postfix/

RUN ["chmod", "+x", "/etc/postfix/run.sh"]

CMD ["/etc/postfix/run.sh"]

EXPOSE 25
EXPOSE 465
EXPOSE 587
