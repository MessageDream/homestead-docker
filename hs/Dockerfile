FROM ubuntu:16.04

LABEL maintainer="https://github.com/MessageDream"

ENV DEBIAN_FRONTEND noninteractive

# Install packages
ADD provision.sh /provision.sh
ADD serve.sh /serve.sh

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN mkdir /works && chmod +x /*.sh && ./provision.sh

EXPOSE 80 22 9900 35729 9876

WORKDIR /works

CMD ["/usr/bin/supervisord"]
