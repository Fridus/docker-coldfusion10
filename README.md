
# Docker CF10

From `finalcut/coldfusion10` : [registry docker](https://hub.docker.com/r/finalcut/coldfusion10/), [github](https://github.com/finalcut/docker-coldfusion10)


## Features

- [cfapi-json-gateway](https://github.com/LoicMahieu/cfapi-json-gateway)
- Apache modules `rewrite` and `headers` enabled
- Packages `curl php5 php5-gd`
- [wkhtmltopdf](http://wkhtmltopdf.org/)
- Better config java
- Default encoding `UTF-8`

#### Config automatically pushed in CF
```
-server -XX:MaxPermSize=1024m -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/coldfusion/heapdump -Xbatch -Dcoldfusion.home={application.home} -Djava.security.egd=file:/dev/./urandom -Dcoldfusion.rootDir={application.home} -Dcoldfusion.libPath={application.home}/lib -Dorg.apache.coyote.USE_CUSTOM_STATUS_MSG_IN_HEADER=true -Dcoldfusion.jsafe.defaultalgo=FIPS186Random -Duser.language=fr -Duser.region=BE -Dsun.io.useCanonCaches=false -Dfile.encoding=UTF-8
```

## Get docker image

### Pull

```
docker pull fridus/coldfusion10
```

### Build

```
docker build -t fridus/coldfusion10 .
```

## Create the docker

```
docker run \
  -d \
  -p 8080:80 \
  -v /your/path:/var/www \
  -h `hostname` \
  --name cf10 \
  fridus/coldfusion10
```

### With custom vhost

```
docker run \
  -d \
  -p 8080:80 \
  -v /your/path:/var/www \
  -v /path/vhost/dir:/etc/apache2/sites-enabled \
  -h `hostname` \
  --name cf10 \
  fridus/coldfusion10
```

Example of custom
```
<VirtualHost *:80>
  DocumentRoot /var/www/website/www
  <Directory />
    AllowOverride All
  </Directory>
</VirtualHost>
```

### With server smtp
With a link smtp, the mail server is automatically configured. The internal name must be `smtp`
```
docker run \
  -d \
  -p 8080:80 \
  -v /var/www:/var/www \
  -h `hostname` \
  --link mailcatcher:smtp
  --name cf10 \
  fridus/coldfusion10
```

### With a datasource configured

#### One datasource

- `DATASOURCE_NAME`: required
- `DATASOURCE_HOST`: required
- `DATASOURCE_USER`: `root`
- `DATASOURCE_PASSWORD`: `""`
- `DATASOURCE_DB`: `DATASOURCE_NAME` if not defined
- `DATASOURCE_ARGS`: optional

```
docker run \
  -d \
  -p 8080:80 \
  -v /var/www:/var/www \
  -h `hostname` \
  --link mailcatcher:smtp
  --name cf10 \
  -e DATASOURCE_NAME=mydatasource \
  -e DATASOURCE_HOST=`ip route get 1 | awk '{print $NF;exit}'` \
  fridus/coldfusion10
```

#### Many datasources

Use `DATASOURCES` in format JSON. `DATASOURCE_HOST` is the default host

```json
[{
  "database": "...",
  "name": "Data source name",
  "password": "...",
  "username": "..."
}, {
  "database": "...",
  "name": "...",
  "password": "...",
  "username": "...",
  "host": "..."
}, {
  "database": "..."
}]
```
```sh
docker run \
  -d \
  -p 8080:80 \
  -v /var/www:/var/www \
  -h `hostname` \
  --link mailcatcher:smtp
  --name cf10 \
  -e DATASOURCES=`cat ./datasources.json` \
  -e DATASOURCE_HOST=`ip route get 1 | awk '{print $NF;exit}'` \
  fridus/coldfusion10
```

### Set serial number

Activate your license, use env `SERIAL`.

```sh
docker run \
  -d \
  -e SERIAL="1234-1234-1234-1234-1234-1234" \
  fridus/coldfusion10
```


## Access

- `/CFIDE/administrator/index.cfm`
- The admin password for the coldfusion server is `Adm1n$`


## Mapping `docker-machine` `boot2docker`

In VirtualBox > Config of VM > Network > Ports mapping
