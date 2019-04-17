FROM alpine:3.8
MAINTAINER Kristof Keppens (kristof.keppens@ugent.be)

# Application settings
ENV CONFD_PREFIX_KEY="/activemq" \
    CONFD_BACKEND="env" \
    CONFD_INTERVAL="60" \
    LANG="en_US.utf8" \
    APP_HOME="/opt/activemq" \
    APP_VERSION="5.15.9" \
    USER=activemq \
    GROUP=root \
    UID=10003 \
    GID=0 \
    CONTAINER_NAME="alpine-activemq" \
    CONTAINER_AUTHOR="Kristof Keppens <kristof.keppens@ugent.be>" \
    CONTAINER_SUPPORT="https://github.com/ICTO/activemq/issues" \
    APP_WEB="http://activemq.apache.org/"

# Install extra package
RUN apk --update add fping curl tar bash openjdk8-jre-base  &&\
    rm -rf /var/cache/apk/*

# Install confd
ENV CONFD_VERSION="0.16.0" \
    CONFD_HOME="/opt/confd"
RUN mkdir -p "${CONFD_HOME}/etc/conf.d" "${CONFD_HOME}/etc/templates" "${CONFD_HOME}/log" "${CONFD_HOME}/bin" &&\
    curl -Lo "${CONFD_HOME}/bin/confd" "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" &&\
    chmod +x "${CONFD_HOME}/bin/confd"

# Install ActiveMQ software
RUN \
    mkdir -p ${APP_HOME} /data /var/log/activemq  && \
    curl http://apache.mirrors.ovh.net/ftp.apache.org/dist/activemq/${APP_VERSION}/apache-activemq-${APP_VERSION}-bin.tar.gz -o /tmp/activemq.tar.gz &&\
    tar -xzf /tmp/activemq.tar.gz -C /tmp &&\
    mv /tmp/apache-activemq-${APP_VERSION}/* ${APP_HOME} &&\
    rm -rf /tmp/activemq.tar.gz &&\
    adduser -g "${USER} user" -D -h ${APP_HOME} -G ${GROUP} -s /bin/sh -u ${UID} ${USER}


ADD files/root /
ADD files/docker-entrypoint.sh /docker-entrypoint.sh

RUN \
    chown -R ${UID}:${GID} ${APP_HOME} &&\
    chown -R ${UID}:${GID} /data &&\
    chown -R ${UID}:${GID} /var/log/activemq && \
    chmod 775 /docker-entrypoint.sh && \ 
    chown ${UID}:${GID} /docker-entrypoint.sh

# Expose all port
EXPOSE 8161
EXPOSE 61616
EXPOSE 5672
EXPOSE 61613
EXPOSE 1883
EXPOSE 61614

VOLUME ["/data", "/var/log/activemq"]
WORKDIR ${APP_HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
