#!/usr/bin/env bash

set -e

_UVERSION=${1:-trusty}
_WVERSION=0.12.2.1
_WVERSION_M=`echo $_WVERSION | awk -F. '{print $1"."$2}'`

FILENAME="wkhtmltox-${_WVERSION}_linux-${_UVERSION}-amd64.deb"
URL="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${_WVERSION}/wkhtmltox-${_WVERSION}_linux-${_UVERSION}-amd64.deb"
apt-get -qq update
apt-get -qq install -y xvfb xfonts-75dpi
mkdir -p /tmp/wkhtml && cd /tmp/wkhtml
wget $URL
dpkg -i ${FILENAME} && \
  cd && rm -rf /tmp/wkhtml

exit 0
