#!/bin/sh

source AWS_ENV

./gets3files -bucket=${S3_BUCKET} -directory=${S3_DIR} -region=${AWS_REGION} ca.crt crl.pem dh4096.pem server.crt server.key ta.key
files="server.key ta.key"
chmod 0640 $files
chgrp nogroup $files
cp -p crl.pem jail
chown nobody:nogroup ipp.txt

exec openvpn $*
