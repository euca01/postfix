FROM alpine:3.18

ENV TZ=Europe/Paris

RUN apk add --no-cache bash postfix postfix-mysql ca-certificates spamassassin-client tzdata && \
       ln -s /usr/share/zoneinfo/$TZ /etc/localtime && \
       adduser -u 1000 -h /var/mail -D vmail vmail

COPY config/ /etc/postfix/

RUN ["chmod", "+x", "/etc/postfix/run.sh"]

CMD ["/etc/postfix/run.sh"]

EXPOSE 25
EXPOSE 465
EXPOSE 587
