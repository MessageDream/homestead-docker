FROM ubuntu:16.04

LABEL maintainer="https://github.com/MessageDream"

ENV DEBIAN_FRONTEND noninteractive
ENV WORK_DIR /home/homestead/works

# Install packages
ADD provision.sh /provision.sh
ADD serve.sh /serve.sh

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN chmod +x /*.sh && ./provision.sh 

VOLUME [ "$WORK_DIR" ]

EXPOSE 80 22 9900 35729 9876

CMD ["/usr/bin/supervisord"]
