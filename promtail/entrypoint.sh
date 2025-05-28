#!/bin/sh

PROMTAIL=/usr/bin/promtail
ARGS="-config.file=$PROMTAIL_CONFIG"

PROMTAIL_COMMAND="$PROMTAIL -config.file=$PROMTAIL_CONFIG $PROMTAIL_ARGS"

if test -f "$PROMTAIL_CONFIG"
then
    set -x
    exec "$PROMTAIL_COMMAND"
    exit $?
fi

if test -z "$APP_PATH_LOGS"
then
    echo "Empty APP_PATH_LOGS at env"
    exit 255
fi

if test -z "$LOKI_URL"
then
    LOKI_URL=http://loki:3100/loki/api/v1/push
fi

echo "WRITE promtail config /etc/promtail.yaml"
cat <<EOF | tee "$PROMTAIL_CONFIG"
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: ${LOKI_URL}

scrape_configs:
  - job_name: app-logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: app-logs
          __path__: /logs/*.log
          app: ${POD_NAME}
          namespace: ${POD_NAMESPACE}
EOF

ARGS="${ARGS} $@"

echo "Executing promtail..."

set -x
exec "$PROMTAIL_COMMAND"
exit $?
