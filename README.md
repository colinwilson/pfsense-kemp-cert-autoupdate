## Bash script that auto-updates certificates on KEMPs Loadmaster Load balancer via pfSense's ACME package.

#### Instructions

See https://colinwilson.uk/2017/06/19/auto-update-ssl-certificates-on-kemp-loadmaster-via-pfsense-lets-encrypt/

Upload the script to a custom location in your pfSense (e.g. `/home/custom/`).

Add the script execution command to the 'Action List' of your desired certificate configuration. e.g.

`sh /home/custom/kemp-cert-update.sh -f /home/custom/cert-auto-update.cert.pem -d mydomain.com -i 172.16.2.10`