#!/bin/sh

#
# Title: Auto-Update & Upload LetsEncrypt Certs to KEMP LoadMaster
# Guide/Source: https://colinwilson.uk/2017/06/19/auto-update-ssl-certificates-on-kemp-loadmaster-via-pfsense--lets-encrypt/
# Created: 12/06/2017
# Author: Colin Wilson @colinwilson
# Vendor or Software Link: https://www.pfsense.org/ , https://kemptechnologies.com
# Version: 1.1.0
# Category: BASH Shell Script
# Tested on: pfSense 2.3.4 & KEMP LM 7.2.38
#
# e.g. sh /home/custom/kemp-cert-update.sh -f /home/custom/cert-auto-update.cert.pem -d mydomain.com -i 172.16.2.10

while [ -n "$1" ]

do

    case "$1" in

            -f|--file)
            KEMP_API_ACCESS_CERT_PATH="$2"
            shift # past argument
            ;;
            -b|--basicauth)
            BASIC_AUTH="$2"
            shift # past argument
            ;;
            -d|--domain)
            CERT_NAME="$2"
            shift # past argument
            ;;
            -i|--ipaddress)
            KEMP_IP="$2"
            shift # past argument
            ;;
            *) # unknown option
            ;;
    esac

    shift # past argument or value

done

# Check if certificate name exists on KEMP LoadMaster
if [ -z "$KEMP_API_ACCESS_CERT_PATH" ]
then
    :
else
LIST_CERTS=$(curl -sS -k -E "$KEMP_API_ACCESS_CERT_PATH" https://"${KEMP_IP}"/access/listcert | xmllint --format --xpath "boolean(//name[text()='$CERT_NAME'])" - )

fi

if [ -z "$BASIC_AUTH" ]
then
    :
else
LIST_CERTS=$(curl -sS -k https://"${BASIC_AUTH}"@"${KEMP_IP}"/access/listcert | xmllint --format --xpath "boolean(//name[text()='$CERT_NAME'])" - )

fi

if [ "$LIST_CERTS" = true ] ; then
    REPLACE=1
else
    REPLACE=0
fi

# Concatenate certificate and key
cat /tmp/acme/"${CERT_NAME}"/"${CERT_NAME}"/"$CERT_NAME".cer /tmp/acme/"${CERT_NAME}"/"${CERT_NAME}"/"$CERT_NAME".key > /tmp/acme/"${CERT_NAME}"/"${CERT_NAME}"/"$CERT_NAME".full.pem

# Upload certificate to KEMP LoadMaster
if [ -z "$BASIC_AUTH" ]
then
    :
else
      upload_cert_basic() {
            curl -sS -X POST --data-binary "@/tmp/acme/${CERT_NAME}/${CERT_NAME}/${CERT_NAME}.full.pem" -k "https://${BASIC_AUTH}@${KEMP_IP}/access/addcert?cert=${CERT_NAME}&replace=${REPLACE}"
        }

      upload_cert_basic
fi

if [ -z "$KEMP_API_ACCESS_CERT_PATH" ]
then
    :
else
      upload_cert() {
            curl -sS -X POST --data-binary "@/tmp/acme/${CERT_NAME}/${CERT_NAME}/${CERT_NAME}.full.pem" -k -E "$KEMP_API_ACCESS_CERT_PATH" "https://${KEMP_IP}/access/addcert?cert=${CERT_NAME}&replace=${REPLACE}"
        }
      upload_cert
fi

# Delete concatenated certificate file
rm /tmp/acme/"${CERT_NAME}"/"${CERT_NAME}"/"$CERT_NAME".full.pem