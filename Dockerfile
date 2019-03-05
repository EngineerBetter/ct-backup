FROM ruby:2.4

COPY fly /usr/bin/fly
COPY credhub /usr/bin/credhub
COPY install_binaries.sh .
RUN ./install_binaries.sh

ADD scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*

COPY verify_image.sh /tmp/verify_image.sh
RUN /tmp/verify_image.sh && rm /tmp/verify_image.sh
