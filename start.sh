#!/bin/bash

if [ -z "$DOMAINS" ] ; then
  echo "No domains set, please fill -e 'DOMAINS=example.com www.example.com'"
  exit 1
fi

if [ -z "$EMAIL" ] ; then
  echo "No email set, please fill -e 'EMAIL=your@email.tld'"
  exit 1
fi

if [ -z "$WEBROOT_PATH" ] ; then
  echo "No webroot path set, please fill -e 'WEBROOT_PATH=/tmp/letsencrypt'"
  exit 1
fi

DARRAYS=(${DOMAINS})
EMAIL_ADDRESS=${EMAIL}
LE_DOMAINS=("${DARRAYS[*]/#/-d }")

exp_limit="${EXP_LIMIT:-30}"
check_freq="${CHECK_FREQ:-30}"

le_hook() {
    if ! [ -z "$RESTART_HOOK" ] ; then
        docker kill -s HUP $RESTART_HOOK
    fi
}

le_fixpermissions() {
    echo "[INFO] Fixing permissions"
        chown -R ${CHOWN:-root:root} /etc/letsencrypt
        find /etc/letsencrypt -type d -exec chmod 755 {} \;
        find /etc/letsencrypt -type f -exec chmod ${CHMOD:-644} {} \;
}

le_renew() {
    certbot certonly --webroot --agree-tos --renew-by-default --text --email ${EMAIL_ADDRESS} -w ${WEBROOT_PATH} ${LE_DOMAINS}
    le_fixpermissions
    le_hook
}

le_check() {
    cert_file="/etc/letsencrypt/live/$DARRAYS/fullchain.pem"
    
    if [ -f $cert_file ]; then
      le_renew
      echo "Renewal process finished for domain $DARRAYS"

    else
      echo "[INFO] certificate file not found for domain $DARRAYS. Starting webroot initial certificate request script..."
      le_renew
      echo "Certificate request process finished for domain $DARRAYS"
    fi

    if [ "$1" != "once" ]; then
        sleep ${check_freq}d
        le_check
    fi
}

le_check $1
