#!/bin/bash

echo "### starting confd "
${CONFD_HOME}/bin/confd -confdir ${CONFD_HOME}/etc -onetime -backend ${CONFD_BACKEND} ${PREFIX} ${NODE}

echo "### starting activemq"
echo "Run as `id`"
ls -l /opt/activemq
ls -l /opt/activemq
ls -l /opt/activemq/conf
ls -l /opt/activemq/data
echo "###"

exec "$@"
