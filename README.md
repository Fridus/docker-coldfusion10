
# Docker CF10

```
docker pull fridus/coldfusion10
docker pull quay.io/fridus/coldfusion10
```

## Features

- [cfapi-json-gateway](https://github.com/LoicMahieu/cfapi-json-gateway)
- Apache modules enabled :
  + `headers`
  + `remoteip`
  + `rewrite`
- Packages `curl php7.0 php7.0-gd`
- [wkhtmltopdf](http://wkhtmltopdf.org/)
- Better config java (see [jvm.config](./build/jvm.config))
- Default encoding `UTF-8`
- redis session

## Create the docker

```sh
docker run -d -p 8080:80 \
  -v /your/path:/var/www \
  fridus/coldfusion10
```

| Variable | Default value | |
|----------|---------------|--------|
| COLDFUSION_ADMIN_PASSWORD | `Adm1n$` | |
| COLDFUSION_SERIAL_NUMBER | | |
| DATASOURCE_ARGS | | |
| DATASOURCE_DB | DATASOURCE_NAME | |
| DATASOURCE_HOST | | |
| DATASOURCE_NAME | | |
| DATASOURCE_PASSWORD | empty | |
| DATASOURCE_USER | `root` | |
| DATASOURCES | | In format JSON. `DATASOURCE_HOST` is the default host, `DATASOURCE_USER` is the default user |
| ENABLE_HIBERNATE_DEBUG | | Set to `true` to keep hibernate debug log active |
| JVM_JAVA_ARGS | See [jvm.config](build/jvm.config) | Overwrite `java.args` |
| OUTPUT_LOGS | `false` | Set to `true` to add the apache and coldfusion logs to the output |
| REDIS_DATABASE | `0` | |
| REDIS_HOST | | |
| REDIS_PORT | | |
| SCHEDULER_CLUSTER_CREATETABLES | false | |
| SCHEDULER_CLUSTER_DSN | | |
| SMTP_PORT_25_TCP_ADDR | | Mail server |
| TIMEZONE | Europe/Brussels | |

### With custom vhost
```sh
docker run -d -p 8080:80 \
  -v /your/path:/var/www \
  -v /path/vhost/dir:/etc/apache2/sites-enabled \
  fridus/coldfusion10
```

Example of custom
```sh
<VirtualHost *:80>
  DocumentRoot /var/www/website/www
  <Directory />
    AllowOverride All
  </Directory>
</VirtualHost>
```

### With server smtp
With a link smtp, the mail server is automatically configured. The internal name must be `smtp`
```sh
docker run -d -p 8080:80 \
  -v /var/www:/var/www \
  --link mailcatcher:smtp
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

```sh
docker run -d -p 8080:80 \
  -v /var/www:/var/www \
  --link mailcatcher:smtp
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
docker run -d -p 8080:80 \
  -v /var/www:/var/www \
  --link mailcatcher:smtp
  -e DATASOURCES=`cat ./datasources.json` \
  -e DATASOURCE_HOST=`ip route get 1 | awk '{print $NF;exit}'` \
  fridus/coldfusion10
```

### Set serial number

Activate your license, use env `COLDFUSION_SERIAL_NUMBER`.

```sh
docker run -d -e COLDFUSION_SERIAL_NUMBER="1234-1234-1234-1234-1234-1234" \
  fridus/coldfusion10
```

### Set Admin password

```sh
docker run -d -e COLDFUSION_ADMIN_PASSWORD="myPassword" fridus/coldfusion10
```

### Redis session

With a link `redis` or environment variables

#### Link
- REDIS_DATABASE (default `0`)

#### Env
- REDIS_HOST
- REDIS_PORT
- REDIS_DATABASE (default `0`)


### Scheduler cluster

#### Env

- SCHEDULER_CLUSTER_DSN
- SCHEDULER_CLUSTER_CREATETABLES

```sh
docker run -d -e SCHEDULER_CLUSTER_DSN="tasks" fridus/coldfusion10
```


## Access

- `/CFIDE/administrator/index.cfm`
- The admin password for the coldfusion server is `Adm1n$`

## About

Projet based on [finalcut/coldfusion10](https://github.com/finalcut/docker-coldfusion10)
