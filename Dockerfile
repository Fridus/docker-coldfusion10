FROM phusion/baseimage:0.10.2
EXPOSE 80 8500
VOLUME ["/var/www", "/tmp/config"]

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Brussels

RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install -y curl wget unzip xsltproc apache2 && \
    cd /tmp && \
    echo " =====> Install Coldfusion" && \
    wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/install.profile && \
    wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/ColdFusion_10_WWEJ_linux64.bin && \
    chmod +x /tmp/ColdFusion_10_WWEJ_linux64.bin && \
    /tmp/ColdFusion_10_WWEJ_linux64.bin -f /tmp/install.profile && \
    rm /tmp/ColdFusion_10_WWEJ_linux64.bin && \
    rm /tmp/install.profile && \
    echo " =====> Disable admin security" && \
    cd /tmp && wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/neo-security-config.sh && \
    chmod +x /tmp/neo-security-config.sh && \
    /tmp/neo-security-config.sh /opt/coldfusion10/cfusion false && \
    echo " =====> Start up the CF server instance and wait for a moment" && \
    /opt/coldfusion10/cfusion/bin/coldfusion start; sleep 30 && \
    echo " =====> Simulate a browser request on the admin UI to complete installation" && \
    curl -L --silent http://localhost:8500/CFIDE/administrator/index.cfm?configServer=true && \
    echo " =====> Stop the CF server instance" && \
    /opt/coldfusion10/cfusion/bin/coldfusion stop && \
    echo " =====> Re-enable admin security" && \
    /tmp/neo-security-config.sh /opt/coldfusion10/cfusion true && \
    rm /tmp/neo-security-config.sh && \
    echo " =====> Apply mandatory hotfix" && \
    cd /tmp && wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/cf10_mdt_updt.jar && \
    /opt/coldfusion10/jre/bin/java -jar /tmp/cf10_mdt_updt.jar -i silent && \
    rm cf10_mdt_updt.jar && \
    echo " =====> Apply hotfix 23" && \
    cd /tmp && wget -q https://cfdownload.adobe.com/pub/adobe/coldfusion/hotfix_023.jar && \
    /opt/coldfusion10/jre/bin/java -jar /tmp/hotfix_023.jar -i silent && \
    rm hotfix_023.jar && \
    echo " =====> Configure Apache2 to run in front of Tomcat" && \
    /opt/coldfusion10/cfusion/runtime/bin/wsconfig -ws Apache -dir /etc/apache2/ -bin /usr/sbin/apache2ctl -script /etc/init.d/apache2 && \
    apt autoremove -y && \
    apt-get remove -y xsltproc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo " =====> Install Apache modules " && \
    a2enmod rewrite headers remoteip expires && \
    echo " =====> Setup Timezone" && \
    apt-get update -qq && apt-get install -y tzdata && \
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata && \
    echo " =====> Install PHP5" && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt install -y php5.6-dev php5.6 php-pear make && \
    pecl channel-update pecl.php.net && \
    pecl -d php_suffix=5.6 install -o -f redis-4.3.0 && \
    rm -rf /tmp/pear && \
    apt-get remove -y php-pear make && \
    apt-get install -y php5.6-gd php5.6-xml php5.6-mbstring && \
    echo " =====> Install wkhtmltopdf" && \
    mkdir -p /tmp/wkhtml && cd /tmp/wkhtml && \
    apt-get -qq install -y xvfb xfonts-75dpi libfontconfig fontconfig libxrender1 libjpeg-turbo8 && \
    wget "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb" -O wkhtmltopdf.deb && \
    dpkg -i wkhtmltopdf.deb && \
    cd && rm -rf /tmp/wkhtml && \
    echo " =====> Install jq" && \
    wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x jq-linux64 && \
    mv jq-linux64 /usr/bin/jq && \
    echo " =====> Clean" && \
    apt autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD ./build/service/ /etc/service/
RUN echo " =====> Coldfusion permissions" && \
    chmod -R 755 /etc/service/coldfusion10
ADD ./build/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config
ADD ./build/coldfusion-service /opt/coldfusion10/cfusion/bin/coldfusion
ADD ./build/cfapi-json-gateway/Gateway.cfc /opt/coldfusion10/cfusion/wwwroot/CFIDE/cfadmin-agent/Gateway.cfc
ADD ./build/tomcat-redis-session/jedis-2.0.0.jar /opt/coldfusion10/cfusion/runtime/lib/jedis-2.0.0.jar
ADD ./build/tomcat-redis-session/tomcat-redis-session-manager-blackboard-1.2.2.jar /opt/coldfusion10/cfusion/runtime/lib/tomcat-redis-session-manager-blackboard-1.2.2.jar
ADD ./build/tomcat-redis-session/commons-pool-1.6.jar /opt/coldfusion10/cfusion/runtime/lib/commons-pool-1.6.jar
ADD ./build/tomcat-redis-session/context.xml /opt/coldfusion10/cfusion/runtime/conf/context.template.xml
ADD ./build/lib/neo-runtime.xml /opt/coldfusion10/cfusion/lib/neo-runtime.xml

RUN chmod 777 /opt/coldfusion10/cfusion/bin/jvm.config && \
    chmod +x /opt/coldfusion10/cfusion/bin/coldfusion && ln -s /opt/coldfusion10/cfusion/bin/coldfusion /etc/init.d/coldfusion
