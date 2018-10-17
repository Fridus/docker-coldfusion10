
FROM finalcut/coldfusion10
LABEL maintainer="detry.florent@gmail.com"

ENV TIMEZONE Europe/Brussels

# jvm config
ADD ./build/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config
RUN chmod 777 /opt/coldfusion10/cfusion/bin/jvm.config

# service
RUN rm -f /opt/coldfusion10/cfusion/bin/coldfusion_bk
ADD ./build/coldfusion-service /opt/coldfusion10/cfusion/bin/coldfusion
RUN chmod +x /opt/coldfusion10/cfusion/bin/coldfusion && ln -s /opt/coldfusion10/cfusion/bin/coldfusion /etc/init.d/coldfusion

# gateway
ADD ./build/cfapi-json-gateway/Gateway.cfc /opt/coldfusion10/cfusion/wwwroot/CFIDE/cfadmin-agent/Gateway.cfc

# apache modules
RUN a2enmod rewrite && a2enmod headers && \
    apt-get -qq update && apt-get install -qq libapache2-mod-rpaf && a2enmod rpaf && \
    rm -rf /var/lib/apt/lists/*

# Timezone
RUN echo $TIMEZONE | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# update packages
RUN apt-get -qq update && \
    apt-get -qq install -y -qq curl wget ca-certificates openssl libssl1.0.0 && \
    rm -rf /var/lib/apt/lists/*

# PHP
RUN apt-get -qq update && \
    apt-get install -y -qq php5 php5-gd && \
    rm -rf /var/lib/apt/lists/*

# wkhtmltopdf
ADD ./build/install_wkhtmltopdf.sh /tmp/install_wkhtmltopdf.sh
RUN /tmp/install_wkhtmltopdf.sh

# jq
RUN wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x jq-linux64 && \
    mv jq-linux64 /usr/bin/jq

ADD ./build/start.sh /start.sh
CMD /start.sh
