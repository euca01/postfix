FROM alpine:3.18

ENV HOSTNAME=srv01.myhostname.com
ENV MAILAME=mymailname
ENV MYDOMAIN=mymailname.com


RUN apk add --no-cache bash postfix ca-certificates

# Configurer Postfix
RUN postconf -e "myhostname = ${HOSTNAME}" && \
    postconf -e "mail_name = ${MAILAME}" && \
    postconf -e 'smtpd_banner = $myhostname ESMTP $mail_name' && \
    postconf -e 'biff = no' && \
    postconf -e 'append_dot_mydomain = no' && \
    postconf -e "mydomain = ${MYDOMAIN}"

CMD ["/usr/sbin/postfix", "start-fg"]

EXPOSE 25
EXPOSE 465
EXPOSE 587
