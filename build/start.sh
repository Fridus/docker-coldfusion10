#!/usr/bin/env bash

_PASSWORD=${CFPASSWORD:-'Adm1n$'}

setConfig () {
  curl -H "X-CF-AdminPassword: ${_PASSWORD}" \
  --data "method=callAPI&wsdl=true&apiComponent=$1&apiMethod=$2&apiArguments=$3" \
  http://127.0.0.1/CF/Gateway.cfc
}

# Start
/sbin/my_init &
sleep 8

# Set mail server
if [ ! -z $SMTP_PORT_25_TCP_ADDR ]; then
  echo "Set Mail Server: $SMTP_PORT_25_TCP_ADDR"
  setConfig mail setMailServer "{\"server\": \"$SMTP_PORT_25_TCP_ADDR\"}"
  echo ''
fi

# Set first datasource
if [ ! -z $DATASOURCE_NAME ]; then
  _DS_HOST=${DATASOURCE_HOST:-''}
  _DS_USER=${DATASOURCE_USER:-'root'}
  _DS_PASS=${DATASOURCE_PASSWORD:-''}
  _DS_DB=${DATASOURCE_DB:-$DATASOURCE_NAME}

  _ARGS="{"
  _ARGS+="\"host\":\"$_DS_HOST\","
  _ARGS+="\"username\":\"$_DS_USER\","
  _ARGS+="\"password\":\"$_DS_PASS\","
  _ARGS+="\"name\":\"$DATASOURCE_NAME\","
  _ARGS+="\"database\":\"$_DS_DB\""
  if [ ! -z $DATASOURCE_ARGS ]; then
    _ARGS+=",\"args\":\"$DATASOURCE_ARGS\""
  fi
  _ARGS+='}'

  echo "Set datasource: $DATASOURCE_NAME"
  setConfig datasource setMySQL5 $_ARGS
fi

wait
