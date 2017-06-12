#!/bin/bash

VER=1.0.0

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

LIST_CERTS=$(curl -sS -k -E $KEMP_USER_CERT_PATH https://${KEMP_IP}/access/listcert | xmllint --format --xpath "boolean(//name[text()='$CERT_NAME'])" - )

cat /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.cer /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.key > /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.full.pem

if [ "$LIST_CERTS" = true ] ; then
    REPLACE=1
else
    REPLACE=0
fi

upload_cert() {
    curl -sS -X POST --data-binary "@/tmp/acme/${CERT_NAME}/${CERT_NAME}/${CERT_NAME}.full.pem" -k -E $KEMP_USER_CERT_PATH "https://${KEMP_IP}/access/addcert?cert=${CERT_NAME}&replace=${REPLACE}"
}

upload_cert

rm /tmp/acme/${CERT_NAME}/${CERT_NAME}/$CERT_NAME.full.pem