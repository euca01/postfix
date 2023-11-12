FROM alpine:3.18

RUN apk add --no-cache postfix postfix-mysql

CMD ["/usr/sbin/postfix"]

EXPOSE 25
EXPOSE 465
EXPOSE 587