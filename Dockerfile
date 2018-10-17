
FROM finalcut/coldfusion10
LABEL maintainer="detry.florent@gmail.com"

ENV TIMEZONE Europe/Brussels

RUN echo "Update packages" && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl wget ca-certificates openssl libssl1.0.0 && \
    echo "Install Apache modules " && \
    a2enmod rewrite && a2enmod headers && \
    apt-get install -y libapache2-mod-rpaf && a2enmod rpaf && \
    echo "Setup Timezone" && \
    echo $TIMEZONE | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata && \
    echo "Install PHP5" && \
    apt-get install -y php5 php5-gd && \
    echo "Install wkhtmltopdf" && \
    apt-get install -y xvfb xfonts-75dpi && \
    wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    rm -f wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    echo "Install jq" && \
    wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x jq-linux64 && \
    mv jq-linux64 /usr/bin/jq && \
    echo "Clean" && \
    rm -rf /var/lib/apt/lists/*

ADD ./build/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config
ADD ./build/coldfusion-service /opt/coldfusion10/cfusion/bin/coldfusion
ADD ./build/cfapi-json-gateway/Gateway.cfc /opt/coldfusion10/cfusion/wwwroot/CFIDE/cfadmin-agent/Gateway.cfc
ADD ./build/start.sh /start.sh

RUN chmod 777 /opt/coldfusion10/cfusion/bin/jvm.config && \
    chmod +x /opt/coldfusion10/cfusion/bin/coldfusion && ln -s /opt/coldfusion10/cfusion/bin/coldfusion /etc/init.d/coldfusion

CMD /start.sh
