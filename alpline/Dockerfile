FROM alpine:latest

LABEL maintainer="https://github.com/MessageDream"

# Install packages
ADD provision.sh /provision.sh
ADD serve.sh /serve.sh

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN apk update && apk upgrade && apk add bash && chmod +x /*.sh

RUN ./provision.sh

EXPOSE 80 22 9900 35729 9876
CMD ["/usr/bin/supervisord"]
