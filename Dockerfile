
FROM alpine:3.19.0
          
RUN apk add --no-cache 'curl' 'unzip' 'bash' 'jq'

ARG CONSUL_TEMPLATE_VERSION=0.36.0
ARG CONSUL_TEMPLATE_URL="https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip"
ADD config /config

RUN curl "${CONSUL_TEMPLATE_URL}" -L -o "/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    chmod u+x /usr/local/bin/consul-template && \
    rm -rf consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    rm -rf /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]


ENTRYPOINT ["/entrypoint.sh"]
