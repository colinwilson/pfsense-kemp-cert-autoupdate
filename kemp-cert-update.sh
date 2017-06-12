#!/bin/sh

###################################################################################
# Title: Auto-Update/Upload LetsEncrypt Certs to KEMP LoadMaster
# Date: 12/06/2017
# Author: Colin Wilson (colin@qunux.com) / Qunux Consulting Ltd
# Vendor or Software Link: https://www.pfsense.org/ / https://kemptechnologies.com
# Version: 1.0.0
# Category: Shell Script
# Tested on: pfSense 2.3.4 & KEMP LM 7.2.38
###################################################################################

while [ -n "$1" ]
 
do
 
    case "$1" in

        -f|--file)
            KEMP_USER_CERT_PATH="$2"
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
            --default)
            DEFAULT=YES
            ;;
            *)
                    # unknown option
            ;;
    esac

    shift # past argument or value
    
done

# Check if certificate name exists on KEMP LoadMaster
LIST_CERTS=$(curl -sS -k -E $KEMP_USER_CERT_PATH https://${KEMP_IP}/access/listcert | xmllint --format --xpath "boolean(//name[text()='$CERT_NAME'])" - )

if [ "$LIST_CERTS" = true ] ; then
    REPLACE=1
else
    REPLACE=0
fi

# Concatenate certificate and key
cat /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.cer /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.key > /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.full.pem

# Upload certificate to KEMP LoadMaster
upload_cert() {
    curl -sS -X POST --data-binary "@/tmp/acme/${CERT_NAME}/${CERT_NAME}/${CERT_NAME}.full.pem" -k -E $KEMP_USER_CERT_PATH "https://${KEMP_IP}/access/addcert?cert=${CERT_NAME}&replace=${REPLACE}"
}

upload_cert

# Delete concatenated certificate file
rm /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.full.pem