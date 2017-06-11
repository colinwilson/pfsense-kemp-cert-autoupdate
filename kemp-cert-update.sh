#!/bin/bash

VER=1.0.0

#Define variables

KEMP_IP="172.16.2.10"
KEMP_USER_CERT_PATH="/tmp/certs/cert-auto-update.cert.pem"
CERT_NAME="fw02-pfsense-sbg-1.qunux.com"

LIST_CERTS=$(curl -sS -k -E $KEMP_USER_CERT_PATH https://${KEMP_IP}/access/listcert | xmllint --format --xpath "boolean(//name[text()='$CERT_NAME'])" - )
#echo "$LIST_CERTS"

cd /tmp/acme/${CERT_NAME}/${CERT_NAME}/ && cat $CERT_NAME.cer $CERT_NAME.key >> $CERT_NAME.full.pem && cd /tmp/acme/${CERT_NAME}/${CERT_NAME}/

if [ "$LIST_CERTS" = true ] ; then
REPLACE=1
else
REPLACE=0
fi

UPLOAD=$(curl -sS -X POST --data-binary "@${CERT_NAME}.full.pem" -k -E $KEMP_USER_CERT_PATH "https://${KEMP_IP}/access/addcert?cert=${CERT_NAME}&replace=${REPLACE}")
echo "$UPLOAD"

rm /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.full.pem && cd ~