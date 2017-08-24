#!/usr/bin/env bash

_PASSWORD=${CFPASSWORD:-'Adm1n$'}
_DEFAULT_HOST=${DATASOURCE_HOST:-''}

setConfig () {
  curl -H "X-CF-AdminPassword: ${_PASSWORD}" \
  --data "method=callAPI&wsdl=true&apiComponent=$1&apiMethod=$2&apiArguments=$3" \
  http://127.0.0.1/CF/Gateway.cfc
}

buildDatasource () {
  _DS_TYPE=${DATASOURCE_TYPE:-'setMySQL5'}
  _DS_HOST=${DATASOURCE_HOST:-$_DEFAULT_HOST}
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

  echo ''
  echo "Set datasource: $DATASOURCE_NAME"
  setConfig datasource $_DS_TYPE $_ARGS
}

setJsonVar () {
  if [ ! -z "$2" ] && [ "$2" != "null" ]; then
    eval "${1}=\$$2"
  fi
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

# Set datasource
if [ ! -z $DATASOURCE_NAME ]; then
  buildDatasource
fi

# set datasources
if [ ! -z "$DATASOURCES" ]; then
  while read -r _DS
  do
    setJsonVar DATASOURCE_TYPE `echo $_DS | jq 'fromjson | .type'`
    setJsonVar DATASOURCE_HOST `echo $_DS | jq 'fromjson | .host'`
    setJsonVar DATASOURCE_USER `echo $_DS | jq 'fromjson | .username'`
    setJsonVar DATASOURCE_PASSWORD `echo $_DS | jq 'fromjson | .password'`
    setJsonVar DATASOURCE_DB `echo $_DS | jq 'fromjson | .database'`
    _DSNAME=`echo $_DS | jq 'fromjson | .name'`
    if [ "$_DSNAME" != "null" ]; then
      eval "DATASOURCE_NAME=\$$_DSNAME"
    else
      DATASOURCE_NAME=$DATASOURCE_DB
    fi

    buildDatasource
  done < <(echo $DATASOURCES | jq '.[] | tojson')
fi

wait
