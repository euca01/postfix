FROM alpine:3.18

RUN apk add --no-cache postfix postfix-mysql

# Configurer Postfix
RUN postconf -e 'smtpd_banner = $myhostname ESMTP $mail_name' && \
    postconf -e 'biff = no' && \
    postconf -e 'append_dot_mydomain = no' && \
    postconf -e 'myhostname = test.berna.fr' && \
    postconf -e 'myorigin = /etc/mailname'


CMD ["/usr/sbin/postfix", "start"]

EXPOSE 25
EXPOSE 465
EXPOSE 587
