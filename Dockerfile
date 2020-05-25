FROM debian:10-slim

RUN apt update && \
    apt install ruby git curl certbot host -y

COPY hooks /opt/certboot-hooks
COPY dns_hooks /usr/bin
COPY lib /usr/lib

WORKDIR /opt/certboot-hooks/

RUN chmod ug+x -R /opt/certboot-hooks && \
    chmod ug+x /usr/bin/dns_hooks && \
    chmod ug+r /usr/lib/request.rb

ENTRYPOINT /usr/bin/dns_hooks
