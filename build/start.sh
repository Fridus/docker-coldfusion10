#!/usr/bin/env bash

_PASSWORD=${CFPASSWORD:-'Adm1n$'}
_CURL="curl -X GET -H \"X-CF-AdminPassword: ${_PASSWORD}\" "
_URL='http://127.0.0.1/CF/Gateway.cfc?method=callAPI&wsdl=true&apiComponent=mail&apiMethod=setMailServer&apiArguments=%7B%22server%22%3A+%22SMTP_PORT_25_TCP_ADDR%22+%7D'

# Start
/sbin/my_init &

# Set mail server
if [ ! -z $SMTP_PORT_25_TCP_ADDR ]; then
  _URL=`echo $_URL | sed -e "s,SMTP_PORT_25_TCP_ADDR,$SMTP_PORT_25_TCP_ADDR,"`
  sleep 5
  _callapi="$_CURL '$_URL'"
  echo "Set Mail Server: $SMTP_PORT_25_TCP_ADDR "
  eval $_callapi
fi

wait
