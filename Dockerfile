FROM alpine:3.18

RUN apk add --no-cache bash postfix postfix-mysql ca-certificates spamassassin-client

COPY config/ /etc/postfix/

RUN ["chmod", "+x", "/etc/postfix/run.sh"]
CMD ["/etc/postfix/run.sh"] 
#CMD ["/usr/sbin/postfix", "start-fg"]

EXPOSE 25
EXPOSE 465
EXPOSE 587
