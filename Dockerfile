
FROM finalcut/coldfusion10
MAINTAINER fridus detry.florent@gmail.com

# jvm config
ADD ./build/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config
RUN chmod 777 /opt/coldfusion10/cfusion/bin/jvm.config

# service
RUN mv /opt/coldfusion10/cfusion/bin/coldfusion /opt/coldfusion10/cfusion/bin/coldfusion_bk
ADD ./build/coldfusion-service /opt/coldfusion10/cfusion/bin/coldfusion
RUN chmod +x /opt/coldfusion10/cfusion/bin/coldfusion
RUN ln -s /opt/coldfusion10/cfusion/bin/coldfusion /etc/init.d/coldfusion

# gateway
ADD ./build/cfapi-json-gateway/Gateway.cfc /var/www/CF/Gateway.cfc

# apache modules
RUN a2enmod rewrite
RUN a2enmod headers

# wkhtmltopdf
RUN apt-get update
RUN apt-get install -y curl php5 php5-gd
RUN sh -c "$(curl -fsSL https://gist.githubusercontent.com/Fridus/60a7604a6f3bc199d3b7/raw/23725ab0da1ce08726f33c2eecff8459b841bbbc/install.sh)"  -- trusty

# Timezone
RUN echo Europe/Brussels | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata
