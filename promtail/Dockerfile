FROM grafana/promtail:2.9.0

USER 1001:1001
LABEL author="Novi Ardi <noone.nu1@gmail.com>"

ENV PROMTAIL_CONFIG=/etc/promtail.yaml
ENV PROMTAIL_ARGS=""

COPY entrypoint.sh /bin/

ENTRYPOINT ["/bin/entrypoint.sh"]
