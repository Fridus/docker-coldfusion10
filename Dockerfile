FROM phusion/baseimage:0.9.9
EXPOSE 80 8500
VOLUME ["/var/www", "/tmp/config"]

ENV DEBIAN_FRONTEND noninteractive
ENV REFRESHED_AT 2018_10_19
ENV TIMEZONE Europe/Brussels

ADD ./build/service/ /etc/service/

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
    curl -v http://localhost:8500/CFIDE/administrator/index.cfm?configServer=true && \
    echo " =====> Stop the CF server instance" && \
    /opt/coldfusion10/cfusion/bin/coldfusion stop && \
    echo " =====> Re-enable admin security" && \
    /tmp/neo-security-config.sh /opt/coldfusion10/cfusion true && \
    rm /tmp/neo-security-config.sh && \
    echo " =====> Apply mandatory hotfix" && \
    cd /tmp && wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/cf10_mdt_updt.jar && \
    /opt/coldfusion10/jre/bin/java -jar /tmp/cf10_mdt_updt.jar -i silent && \
    rm cf10_mdt_updt.jar && \
    echo " =====> Apply hotfix 13" && \
    cd /tmp && wget -q https://s3-eu-west-1.amazonaws.com/igloo-devops/coldfusion10-install/hotfix_013.jar && \
    /opt/coldfusion10/jre/bin/java -jar /tmp/hotfix_013.jar -i silent && \
    rm hotfix_013.jar && \
    echo " =====> Configure Apache2 to run in front of Tomcat" && \
    /opt/coldfusion10/cfusion/runtime/bin/wsconfig -ws Apache -dir /etc/apache2/ -bin /usr/sbin/apache2 -script /etc/init.d/apache2 && \
    echo " =====> Coldfusion permissions" && \
    chmod -R 755 /etc/service/coldfusion10 && \
    echo " =====> Install Apache modules " && \
    a2enmod rewrite && a2enmod headers && \
    apt-get install -y libapache2-mod-rpaf && a2enmod rpaf && \
    echo " =====> Setup Timezone" && \
    apt-get install -y tzdata && \
    echo $TIMEZONE | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata && \
    echo " =====> Install PHP5" && \
    apt-get install -y php5 php5-gd php-pear make && \
    pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    apt-get remove -y php-pear make && \
    echo " =====> Install wkhtmltopdf" && \
    apt-get install -y xvfb xfonts-75dpi libfontconfig wkhtmltopdf && \
    echo " =====> Install jq" && \
    wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x jq-linux64 && \
    mv jq-linux64 /usr/bin/jq && \
    echo " =====> Clean" && \
    apt-get remove -y xsltproc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD ./build/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config
ADD ./build/coldfusion-service /opt/coldfusion10/cfusion/bin/coldfusion
ADD ./build/cfapi-json-gateway/Gateway.cfc /opt/coldfusion10/cfusion/wwwroot/CFIDE/cfadmin-agent/Gateway.cfc
ADD ./build/tomcat-redis-session/jedis-2.0.0.jar /opt/coldfusion10/cfusion/runtime/lib/jedis-2.0.0.jar
ADD ./build/tomcat-redis-session/tomcat-redis-session-manager-blackboard-1.2.2.jar /opt/coldfusion10/cfusion/runtime/lib/tomcat-redis-session-manager-blackboard-1.2.2.jar
ADD ./build/tomcat-redis-session/commons-pool-1.6.jar /opt/coldfusion10/cfusion/runtime/lib/commons-pool-1.6.jar
ADD ./build/tomcat-redis-session/context.xml /opt/coldfusion10/cfusion/runtime/conf/context.template.xml
ADD ./build/lib/neo-runtime.xml /opt/coldfusion10/cfusion/lib/neo-runtime.xml
ADD ./build/start.sh /start.sh

RUN chmod 777 /opt/coldfusion10/cfusion/bin/jvm.config && \
    chmod +x /opt/coldfusion10/cfusion/bin/coldfusion && ln -s /opt/coldfusion10/cfusion/bin/coldfusion /etc/init.d/coldfusion

CMD /start.sh
