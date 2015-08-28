
# Docker CF10

From `finalcut/coldfusion10` : [registry docker](https://hub.docker.com/r/finalcut/coldfusion10/), [github](https://github.com/finalcut/docker-coldfusion10)


## Features

- [cfapi-json-gateway](https://github.com/LoicMahieu/cfapi-json-gateway)
- Apache modules `rewrite` and `headers` enabled
- Packages `curl php5 php5-gd`
- [wkhtmltopdf](http://wkhtmltopdf.org/)
- Better config java

#### Config automatically pushed in CF
```
-server -XX:MaxPermSize=1024m -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/coldfusion/heapdump -Xbatch -Dcoldfusion.home={application.home} -Djava.security.egd=file:/dev/./urandom -Dcoldfusion.rootDir={application.home} -Dcoldfusion.libPath={application.home}/lib -Dorg.apache.coyote.USE_CUSTOM_STATUS_MSG_IN_HEADER=true -Dcoldfusion.jsafe.defaultalgo=FIPS186Random -Duser.language=fr -Duser.region=BE -Dsun.io.useCanonCaches=false
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
  -v /var/www:/var/www \
  -v /path/vhost:/etc/apache2/sites-enabled \
  -h `hostname` \
  --name cf10 \
  fridus/coldfusion10
```


## Access

- The admin password for the coldfusion server is `Adm1n$`
- port `8080`


## Mapping `docker-machine` `boot2docker`

In VirtualBox > Config of VM > Network > Ports mapping
