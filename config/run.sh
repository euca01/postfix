#!/bin/bash

function add_config_value() {
  local key=${1}
  local value=${2}
  # local config_file=${3:-/etc/postfix/main.cf}
  [ "${key}" == "" ] && echo "ERROR: No key set !!" && exit 1
  [ "${value}" == "" ] && echo "ERROR: No value set !!" && exit 1

  echo "Setting configuration option ${key} with value: ${value}"
 postconf -e "${key} = ${value}"
}



# Set needed config options
add_config_value "myhostname" "${HOSTNAME}"
add_config_value "mydomain" "${MYDOMAIN}"
#add_config_value "mydestination" "${MYDOMAIN}"
add_config_value "myorigin" "${MYDOMAIN}"



# Personnalisation de la configuration
sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/mysql-canonical.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/mysql-canonical.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/mysql-canonical.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/mysql-canonical.cf

sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/mysql-smtpd_sender_login_maps.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/mysql-smtpd_sender_login_maps.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/mysql-smtpd_sender_login_maps.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/mysql-smtpd_sender_login_maps.cf

sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/mysql-virtual_alias_maps.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/mysql-virtual_alias_maps.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/mysql-virtual_alias_maps.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/mysql-virtual_alias_maps.cf

sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/mysql-virtual_mailbox_domains.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/mysql-virtual_mailbox_domains.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/mysql-virtual_mailbox_domains.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/mysql-virtual_mailbox_domains.cf

sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/mysql-virtual_mailbox_maps.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/mysql-virtual_mailbox_maps.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/mysql-virtual_mailbox_maps.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/mysql-virtual_mailbox_maps.cf

sed -i "s/DB_PASSWORD/${DB_PASSWORD}/g" /etc/postfix/sql/tls_policy_sql.cf
sed -i "s/DB_USER/${DB_USER}/g" /etc/postfix/sql/tls_policy_sql.cf
sed -i "s/DB_DATABASE/${DB_DATABASE}/g" /etc/postfix/sql/tls_policy_sql.cf
sed -i "s/DB_HOST/${DB_HOST}/g" /etc/postfix/sql/tls_policy_sql.cf


if [ -f "/etc/letsencrypt/live/${DOMAINSSL}/fullchain.pem" ]; then
    add_config_value "smtpd_tls_cert_file" "/etc/letsencrypt/live/${DOMAINSSL}/fullchain.pem"
    add_config_value "smtpd_tls_key_file" "/etc/letsencrypt/live/${DOMAINSSL}/privkey.pem"
    add_config_value "smtp_tls_cert_file" "/etc/letsencrypt/live/${DOMAINSSL}/fullchain.pem"
    add_config_value "smtp_tls_key_file" "/etc/letsencrypt/live/${DOMAINSSL}/privkey.pem"


    if [ ! -f "/etc/postfix/dh2048.pem" ]; then
        openssl dhparam -out /etc/postfix/dh2048.pem 2048
    fi

fi




#Start services
## Modification des routes pour répondre en SMTP via le VPN
ip route del default 
ip route add default via 172.100.0.250 dev eth0
#ip route add default via 10.8.0.1 dev eth0
ip route add 192.168.0.0/16 via 172.100.0.1 dev eth0
ip route add 10.8.0.0/24 via 172.100.0.250

ip -6 route del default via 2001:db8:100::1 dev eth0  metric 1024
ip -6 route add default via 2001:db8:100::250 dev eth0  metric 1024

#Force custom DNS
#echo "nameserver 172.100.0.220" > /etc/resolv.conf 

# If host mounting /var/spool/postfix, we need to delete old pid file before
# starting services
rm -f /var/spool/postfix/pid/master.pid
/usr/sbin/postalias /etc/postfix/aliases

exec /usr/sbin/postfix -c /etc/postfix start-fg
